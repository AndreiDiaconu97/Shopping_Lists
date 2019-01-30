<%@page import="java.sql.Timestamp"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.function.Predicate"%>
<%@page import="db.daos.jdbc.JDBC_utility.SortBy"%>
<%@page import="db.entities.Message"%>
<%@page import="org.json.JSONObject"%>
<%@page import="org.json.JSONArray"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.ArrayList"%>
<%@page import="db.entities.Product"%>
<%@page import="db.entities.Prod_category"%>
<%@page import="db.daos.ProductDAO"%>
<%@page import="db.daos.jdbc.JDBC_utility"%>
<%@page import="db.daos.jdbc.JDBC_utility.AccessLevel"%>
<%@page import="java.util.Arrays"%>
<%@page import="db.daos.List_categoryDAO"%>
<%@page import="db.daos.UserDAO"%>
<%@page import="db.entities.List_category"%>
<%@page import="db.entities.List_reg"%>
<%@page import="java.util.List"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="my" tagdir="/WEB-INF/tags" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="db.factories.DAOFactory"%>
<%@page import="db.exceptions.DAOFactoryException"%>
<%@page import="db.exceptions.DAOException"%>
<%@page import="db.entities.User"%>
<%@page import="db.daos.List_regDAO"%>


<%!
    private UserDAO userDao;
    private List_regDAO list_regDao;
    private List_categoryDAO list_catDao;
    private ProductDAO productDao;

    public void jspInit() {
        DAOFactory daoFactory = (DAOFactory) super.getServletContext().getAttribute("daoFactory");
        if (daoFactory == null) {
            throw new RuntimeException(new ServletException("Impossible to get dao factory"));
        }
        try {
            userDao = daoFactory.getDAO(UserDAO.class);
        } catch (DAOFactoryException ex) {
            throw new RuntimeException(new ServletException("Impossible to get dao for user", ex));
        }
        try {
            list_regDao = daoFactory.getDAO(List_regDAO.class);
        } catch (DAOFactoryException ex) {
            throw new RuntimeException(new ServletException("Impossible to get the dao for list", ex));
        }
        try {
            list_catDao = daoFactory.getDAO(List_categoryDAO.class);
        } catch (DAOFactoryException ex) {
            throw new RuntimeException(new ServletException("Impossible to get the dao for list_cat", ex));
        }
        try {
            productDao = daoFactory.getDAO(ProductDAO.class);
        } catch (DAOFactoryException ex) {
            throw new RuntimeException(new ServletException("Impossible to get the dao for product", ex));
        }
    }

    public void jspDestroy() {
        if (userDao != null) {
            userDao = null;
        }
        if (list_regDao != null) {
            list_regDao = null;
        }
        if (list_catDao != null) {
            list_catDao = null;
        }
    }
%>
<%
    String contextPath = getServletContext().getContextPath();
    if (!contextPath.endsWith("/")) {
        contextPath += "/";
    }
    pageContext.setAttribute("contextPath", contextPath);

    // get user
    User user = (User) session.getAttribute("user");

    // check shopping list
    String listID_s = request.getParameter("listID");
    if ((listID_s == null) || (listID_s.equals(""))) {
        if (!response.isCommitted()) {
            response.sendRedirect(response.encodeRedirectURL(contextPath + "restricted/homepage.html"));
        }
        return;
    }
    Integer listID = Integer.parseInt(listID_s);

    // retrieve list
    List_reg list = null;
    try {
        list = list_regDao.getByPrimaryKey(listID);
        pageContext.setAttribute("list", list);
    } catch (DAOException ex) {
        System.err.println("Error retrieving shopping lists (jsp)" + ex);
        if (!response.isCommitted()) {
            response.sendRedirect(contextPath + "error.html?error=");
        }
        return;
    }
    if (list == null) {
        System.err.println("List not found");
        if (!response.isCommitted()) {
            response.sendRedirect(response.encodeRedirectURL(contextPath + "restricted/homepage.html"));
        }
        return;
    }

    //check visibility
    if (!(user.equals(list.getOwner())) && !(list_regDao.getUsersSharedTo(list)).contains(user)) {
        System.err.println("Access to this list DENIED");
        if (!response.isCommitted()) {
            response.sendRedirect(response.encodeRedirectURL(contextPath + "restricted/homepage.html"));
        }
        return;
    }

    try {
        List<Prod_category> prod_categories = list_catDao.getProd_categories(list.getCategory(), true);
        pageContext.setAttribute("prod_categories", prod_categories);

        List<Product> listProducts = list_regDao.getProducts(list);
        pageContext.setAttribute("listProducts", listProducts);

        JSONArray listProductsJSON = new JSONArray();
        for (Product p : listProducts) {
            int purchased = list_regDao.getAmountPurchased(list, p);
            int total = list_regDao.getAmountTotal(list, p);
            Timestamp last_purchase = list_regDao.getLastPurchase(list, p);
            JSONObject pJSON = Product.toJSON(p);
            pJSON.put("purchased", purchased);
            pJSON.put("total", total);
            pJSON.put("last_purchase", last_purchase);
            listProductsJSON.put(pJSON);
        }
        pageContext.setAttribute("listProductsJSON", listProductsJSON);

        Set<Product> otherProducts = new HashSet<>();
        for (Prod_category p_c : prod_categories) {
            otherProducts.addAll(productDao.filterProducts(null, p_c, user, true, SortBy.POPULARITY));
        }
        otherProducts.removeAll(listProducts);
        pageContext.setAttribute("otherProductsJSON", Product.toJSON(otherProducts));

        List<User> shared_to = list_regDao.getUsersSharedTo(list);
        pageContext.setAttribute("shared_to", shared_to);
        List<User> friends = userDao.getFriends(user);
        friends.removeAll(shared_to);
        pageContext.setAttribute("friends", friends);

        boolean isListOwner = (user.equals(list.getOwner()));
        pageContext.setAttribute("isListOwner", isListOwner);
        pageContext.setAttribute("userDao", userDao);
        pageContext.setAttribute("list_regDao", list_regDao);
        AccessLevel userAccessLevel = isListOwner ? AccessLevel.FULL : userDao.getAccessLevel(user, list);
        pageContext.setAttribute("userAccessLevel", userAccessLevel);
        System.err.println("User access level: " + userAccessLevel);
    } catch (DAOException ex) {
        System.err.println("Error getting some info: " + ex);
    }
%>
<!DOCTYPE html>
<html>

    <head>
        <title>Shopping lists manager</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" charset="UTF-8">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.7.0/css/all.css" integrity="sha384-lZN37f5QGtY3VHgisS14W3ExzMWZxybE1SJSEsQp9S+oqd12jhcu+A56Ebc1zFSJ" crossorigin="anonymous">

        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"></script>
    </head>

    <body>
        <!-- navbar -->
        <nav class="navbar navbar-expand-md navbar-dark bg-dark sticky-top shadow">
            <!-- Title -->
            <a class="navbar-brand" href="homepage.html">
                <i class="fa fa-shopping-cart" style="font-size:30px"></i>
                Shopping lists
            </a>
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarSupportedContent">
                <ul class="nav navbar-nav ml-auto">
                    <li class="dropdown ml-auto my-auto">
                        <div class="text-white mx-2">logged in as <b>${user.email}</b></div>
                    </li>
                    <li class="dropdown ml-auto my-auto">
                        <form class="form-inline" action="${contextPath}auth" method="POST" method="POST">
                            <input class="form-control" type="hidden" name="action" value="logout" required>
                            <button type="submit" class="btn btn-outline-secondary btn-sm">Logout</button>
                        </form>
                    </li>
                </ul>
            </div>
        </nav>

        <!-- name and logo -->
        <div class="container-fluid pt-2 pb-3 mb-2 shadow">
            <div class="container-fluid mx-auto my-auto">
                <div class="col-12 col-sm-7 col-md-3 mx-auto my-2">
                    <img class="img-fluid rounded shadow mx-auto" alt="Responsive image" src="../images/shopping_lists/${list.id}">
                </div>
                <div class="row">
                    <div class="my-auto mr-2" style="text-shadow: 2px 2px 8px #bbbbbb;">
                        <h2>
                            <c:out value="${list.name}" />
                        </h2>
                    </div>
                    <h4>
                        <small>
                            <span class="badge badge-pill badge-secondary shadow mr-2">
                                <c:out value="${list.category.name}" />
                            </span>
                        </small>
                    </h4>
                    <c:if test="${userAccessLevel=='FULL'}">
                        <button type="button" class="btn btn-secondary ml-auto" href="#listSettingsModal" data-toggle="modal">
                            <i class="fa fa-cog" style="font-size:20px"></i>
                        </button>
                    </c:if>
                </div>
            </div>
            <div class="row mx-auto">

            </div>
        </div>

        <!-- owner + chat + participants + share -->
        <div class="container-fluid mb-2 bg-dark text-white">
            <div class="row justify-content-between py-2 mx-auto">
                <p class="font-weight-light mr-2 my-auto" style="color: grey">
                    Created by
                    <span style="color: whitesmoke; font-size: 15pt">
                        <c:out value="${list.owner.firstname} ${list.owner.lastname}" />
                    </span>
                    <span style="color: gray; font-size: 10pt">
                        <c:out value="(${list.owner.email})" />
                    </span>
                </p>
                <button type="button" class="btn btn-dark btn-sm mx-1 ml-auto" href="#chatModal" onclick="scrollChat()" data-toggle="modal">
                    <i class="fa fa-comments" style="font-size:30px; color: graytext"></i>
                </button>
                <c:if test="${isListOwner}">
                    <button type="button" class="btn btn-dark btn-sm mx-1" href="#participantsModal" data-toggle="modal">
                        <i class="fa fa-users" style="font-size:30px; color: graytext"></i>
                    </button>
                    <button type="button" class="btn btn-dark btn-sm mx-1" href="#shareModal" data-toggle="modal">
                        <i class="fa fa-share-alt" style="font-size:30px; color: graytext"></i>
                    </button>
                </c:if>
            </div>
        </div>

        <!-- description spoiler -->
        <div class="container-fluid mb-4">
            <div class="panel panel-success autocollapse">
                <div class="panel-heading clickable">
                    <div class="row mx-auto">
                        <div class="text-left my-auto">
                            <h5>
                                <i class="fa fa-chevron-circle-down mr-2 my-auto" style="font-size:20px;"></i>
                                Description
                            </h5>
                        </div>
                    </div>
                    <hr>
                </div>
                <div class="panel-body">
                    <div class="text-justify mx-4">
                        <c:out value="${list.description}" />
                    </div>
                </div>
            </div>
        </div>

        <!-- products -->
        <div class="card mb-2 shadow border-0">
            <div class="card-header">
                <div class='row'>
                    <div class="row my-auto mr-auto mx-1">
                        <h4 class="my-auto pb-2">Products <small><span class="badge badge-secondary shadow">${list.purchased}/${list.total}</span></small></h4>
                    </div>
                    <div class="row  mx-1">
                        <div class="row ml-auto mr-1 mt-2">
                            <div class="row ml-2 mr-0 my-2">
                                <div class="input-group my-auto">
                                    <select class="custom-select" id="p-search-sort" onchange="showProducts()">
                                        <option value="Name">Name</option>
                                        <option value="Rating">Rating</option>
                                        <option value="Popularity">Popularity</option>
                                    </select>
                                </div>
                            </div>
                            <div class="row mx-2 my-2">
                                <div class="input-group my-auto">
                                    <select class="custom-select" id="p-search-cat" onchange="showProducts()">
                                        <option value="-1" selected>All categories</option>
                                        <c:forEach var="cat" items="${prod_categories}">
                                            <option value="${cat.id}">${cat.name}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                            <div class="row ml-auto mx-2 my-2">
                                <div class="input-group">
                                    <input class="form-control" type="search" placeholder="Search name ..." id="p-search-name" onkeyup="showProducts()">
                                    <button class="btn btn-outline-success" onclick="showProducts()">
                                        <i class="fa fa-search mr-auto" style="font-size:20px;"></i>
                                    </button>
                                    <c:if test="${userAccessLevel=='FULL' || userAccessLevel=='PRODUCTS'}">
                                        <button type="button" class="btn btn-primary ml-2 my-auto shadow rounded-circle" href="#addProductModal" data-toggle="modal">
                                            <i class="fa fa-plus mr-auto"></i>
                                        </button>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>




        <div class="container-fluid">
            <div class="row mx-auto mb-2 justify-content-end">
                <button type="button" class="btn btn-success mr-2 my-auto shadow rounded border" href="#sendPurchasedModal" data-toggle="modal">
                    Confirm
                    <i class="fa fa-check ml-1"></i>
                </button>
                <button type="button" class="btn btn-danger my-auto shadow rounded" onclick="resetPurchased()">
                    Reset
                    <i class="fas fa-redo ml-1"></i>
                </button>
            </div>

            <!-- Missing products (not fully purchased) -->
            <div id="missing-products">
            </div>




            <div class="row mx-auto mb-2 justify-content-end">
                <button type="button" class="btn btn-success mr-2 my-auto shadow rounded" href="#sendPurchasedModal" data-toggle="modal">
                    Confirm
                    <i class="fa fa-check ml-1"></i>
                </button>
                <button type="button" class="btn btn-danger my-auto shadow rounded"  onclick="resetPurchased()">
                    Reset
                    <i class="fas fa-redo ml-1"></i>
                </button>
            </div>



            <!-- Purchased products -->
            <div id="purchased-products">
            </div>
        </div>










        <!-- MODALS -->

        <!-- list settings -->
        <c:if test="${userAccessLevel=='FULL'}">
            <div class="modal modal-fluid" id="listSettingsModal">
                <div class="modal-dialog modal-dialog-centered modal-lg">
                    <div class="modal-content">
                        <div class="modal-header shadow">
                            <i class="fa fa-cog my-auto mr-auto" style="font-size:25px;"></i>
                            <h5 class="modal-title">Shopping list edit</h5>
                            <button type="button" class="close" data-dismiss="modal">
                                <span>&times;</span>
                            </button>
                        </div>
                        <div class="modal-body mx-3">
                            <form id="editListForm" action="${contextPath}restricted/shopping.lists.handler" method="POST" enctype="multipart/form-data">
                                <input type="hidden" name="list_id" value="${list.id}"/>
                                <input type="hidden" name="action" value="edit"/>
                                <div class="md-form mb-3">
                                    <i class="fa fa-image prefix grey-text"></i>
                                    <label data-error="error" data-success="success" for="defaultForm-email">Logo</label>
                                    <div class="custom-file">
                                        <input type="file" class="custom-file-input" id="inputGroupFile01" name="image" accept="image/*">
                                        <label class="custom-file-label" for="inputGroupFile01">Choose file</label>
                                    </div>
                                </div>
                                <div class="md-form mb-3">
                                    <i class="fa fa-bookmark prefix grey-text"></i>
                                    <label data-error="error" data-success="success">List name</label>
                                    <input type="text" class="form-control validate" name="name" value="${list.name}"/>
                                </div>
                                <div class="md-form mb-3">
                                    <i class="fa fa-align-left prefix grey-text"></i>
                                    <label data-error="error" data-success="success">Description</label>
                                    <textarea class="form-control validate" name="description">${list.description}</textarea>
                                </div>
                            </form>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-primary" onclick="$(editListForm)[0].submit()">Confirm<i class="fa fa-check ml-1"></i></button>
                            <button type="button" class="btn btn-danger" data-dismiss="modal">Cancel<i class="fa fa-times ml-1"></i></button>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>

        <!-- chat -->
        <div class="modal modal-fluid" id="chatModal">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content">
                    <div class="modal-header shadow">
                        <i class="fa fa-comments my-auto mr-auto" style="font-size:30px;"></i>
                        <h5 class="modal-title">Group chat</h5>
                        <button type="button" class="close" data-dismiss="modal">
                            <span>&times;</span>
                        </button>
                    </div>
                    <div class="modal-body" id="chatbody" style="height:72vh; overflow-y:scroll; width: 100%">
                        <c:forEach var="message" items="${list_regDao.getMessages(list)}">
                            <div class="row mb-2 ml-0">
                                <div class="col-3 col-md-2">
                                    <div class="row">
                                        <img class="img-thumbnail shadow-sm" style="width: 100px; height: 100%; min-width: 50px; min-height: 100%"
                                             alt="Responsive image" src="../images/avatars/${message.user.id}">
                                    </div>
                                    <div class="row">
                                        ${message.user.firstname} ${message.user.lastname}
                                    </div>
                                </div>
                                <div class="col">
                                    ${message.text}
                                </div>
                            </div>
                            <hr>
                        </c:forEach>
                    </div>
                    <form action="${contextPath}restricted/chat" method="POST" class="modal-footer form-horizontal">
                        <input type="hidden" name="list_id" value="${list.id}">
                        <input class="form-control mr-2" type="text" name="text" style="width: 92%" placeholder="write a message...">
                        <button type="submit" class="btn btn-secondary"><i class="fa fa-arrow-circle-right my-auto" style="font-size:23px;"></i></button>
                    </form>
                </div>
            </div>
        </div>

        <c:if test="${isListOwner}">
            <!-- participants -->
            <div class="modal modal-fluid" id="participantsModal">
                <div class="modal-dialog modal-dialog-centered modal-lg">
                    <div class="modal-content">
                        <div class="modal-header shadow">
                            <i class="fa fa-users my-auto mr-auto" style="font-size:30px;"></i>
                            <h5 class="modal-title">Participants</h5>
                            <button type="button" class="close" data-dismiss="modal">
                                <span>&times;</span>
                            </button>
                        </div>
                        <div class="modal-body" style="height:72vh; overflow-y:scroll; width: 100%">
                            <c:forEach var="shared_user" items="${list_regDao.getUsersSharedTo(list)}">
                                <c:set var="shared_user_al" value="${userDao.getAccessLevel(shared_user, list)}"/>
                                <div class="row mb-2 px-auto ml-0">
                                    <img class="img-thumbnail shadow-sm mr-2" style="width: 70px; height: 100%; min-width: 50px; min-height: 100%" alt="Responsive image" src="../images/avatars/${shared_user.id}">
                                    <p class="mr-2 my-auto">
                                        <c:out value="${shared_user.firstname} ${user.lastname}" />
                                    </p>
                                    <p class="mr-2 my-auto" style="color: grey">
                                        <c:out value="(${shared_user.email})" />
                                    </p>
                                    <div class="row ml-auto mx-2 my-2">
                                        <div class="input-group my-auto">
                                            <select class="custom-select" id="inputGroupSelect02">
                                                <my:n>
                                                    <option value="2" <c:if test="${shared_user_al=='FULL'}">selected</c:if> >FULL</option>
                                                    <option value="1" <c:if test="${shared_user_al=='PRODUCTS'}">selected</c:if> >PRODUCTS</option>
                                                    <option value="0" <c:if test="${shared_user_al=='READ'}">selected</c:if> >READ</option>
                                                </my:n>
                                            </select>
                                            <div class="input-group-append">
                                                <label class="input-group-text" for="inputGroupSelect02">
                                                    <i class="fa fa-wrench"></i>
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                    <button type="button" class="btn btn-danger my-auto mr-2 shadow-sm rounded" data-toggle="button"
                                            >
                                        <i class="fa fa-user-times" style="font-size:25px"></i>
                                    </button>
                                </div>
                                <hr>
                            </c:forEach>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-primary" data-dismiss="modal">Confirm changes</button>
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>

        <c:if test="${isListOwner}">
            <!-- share -->
            <div class="modal modal-fluid" id="shareModal">
                <div class="modal-dialog modal-dialog-centered modal-lg">
                    <div class="modal-content">
                        <div class="modal-header shadow">
                            <i class="fa fa-share-alt my-auto mr-auto" style="font-size:30px;"></i>
                            <h5 class="modal-title ml-2">Share your shopping list</h5>
                            <button type="button" class="close" data-dismiss="modal">
                                <span>&times;</span>
                            </button>
                        </div>

                        <div class="modal-body" style="height:62vh; overflow-y:scroll; width: 100%">
                            <div class="modal-header my-2" style="background-color: #bbbbbb">
                                <h5 class="modal-title ml-2">Recent contacts</h5>
                            </div>
                            <c:forEach var="friend" items="${friends}">
                                <div class="row px-auto ml-0">
                                    <img class="img-thumbnail shadow-sm mr-2 mb-2" style="width: 70px; height: 100%; min-width: 50px; min-height: 100%" alt="Responsive image" src="../images/avatars/${friend.id}">
                                    <p class="mr-2 my-auto">
                                        ${friend.firstname} ${friend.lastname}
                                    </p>
                                    <p class="mr-2 my-auto" style="color: grey">
                                        ${friend.email}
                                    </p>
                                    <div class="row ml-auto mx-2 my-2">
                                        <div class="input-group my-auto">
                                            <select class="custom-select" id="sharePermssionsSelect${friend.id}">
                                                <option value="2">FULL</option>
                                                <option value="1">PRODUCTS</option>
                                                <option value="0" selected>READ</option>
                                            </select>
                                            <div class="input-group-append">
                                                <label class="input-group-text" for="sharePermssionsSelect${friend.id}">
                                                    <i class="fa fa-wrench"></i>
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                    <button type="button" class="btn btn-success my-auto mr-2 shadow-sm rounded" data-toggle="button">
                                        <i class="fa fa-user-plus" style="font-size:25px"></i>
                                    </button>
                                </div>
                                <hr>
                            </c:forEach>
                        </div>
                        <div class="modal-footer">
                            <h5 class="row-sm my-2">Add by email</h5>
                            <input class="form-control" type="text" style="width: 70%" placeholder="Insert user email...">
                            <div class="row my-2">
                                <div class="input-group my-auto">
                                    <select class="custom-select" id="sharePermssionsSelect${friend.id}">
                                        <option value="2">FULL</option>
                                        <option value="1">PRODUCTS</option>
                                        <option value="0" selected>READ</option>
                                    </select>
                                    <div class="input-group-append">
                                        <label class="input-group-text" for="sharePermssionsSelect${friend.id}">
                                            <i class="fa fa-wrench"></i>
                                        </label>
                                    </div>
                                </div>
                            </div>
                            <button type="button" class="btn btn-success mx-auto my-auto shadow-sm rounded" data-toggle="button">
                                <i class="fa fa-user-plus" style="font-size:25px"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>

        <c:if test="${userAccessLevel=='FULL' || userAccessLevel=='PRODUCTS'}">
            <!-- add product -->
            <div class="modal modal-fluid" id="addProductModal">
                <div class="modal-dialog modal-dialog-centered modal-lg">
                    <div class="modal-content">
                        <div class="modal-header shadow">
                            <i class="fa fa-cart-plus my-auto mr-auto" style="font-size:30px;"></i>
                            <h5 class="modal-title">Add product to list</h5>
                            <button type="button" class="close" data-dismiss="modal">
                                <span>&times;</span>
                            </button>
                        </div>

                        <!-- Other products (that can be added) -->
                        <div class="modal-body" id="otherProducts" style="height:72vh; overflow-y:scroll; width: 100%">
                        </div>

                        <div class="modal-footer form-horizontal">
                            <div class="input-group my-auto ml-auto">
                                <select id="p-add-sort" class="custom-select" style="min-width: 90px" onchange="fillProductsAddModal()">
                                    <option value="Name">Name</option>
                                    <option value="Rating">Rating</option>
                                    <option value="Popularity">Popularity</option>
                                </select>
                                <select id="p-add-cat" class="custom-select" style="min-width: 135px" onchange="fillProductsAddModal()">
                                    <option value="-1" selected>All categories</option>
                                    <c:forEach var="cat" items="${prod_categories}">
                                        <option value="${cat.id}">${cat.name}</option>
                                    </c:forEach>
                                </select>
                                <input id="p-add-name" class="form-control" style="min-width: 90px" type="text" placeholder="Search name..." onkeyup="fillProductsAddModal()">
                            </div>
                            <div class="input-group my-auto mr-auto" style="max-width: 200px">
                                <form id="add-Product-Form" action="${contextPath}restricted/shopping.lists.handler" method="POST">
                                    <input type="hidden" name="list_id"value="${list.id}">
                                    <input type="hidden" name="action" value="addProduct">
                                    <input type="hidden" id="add-Product-Hidden-Id" name="product_id">
                                    <input type="number" required id="add-Product-Form-Amount" class="form-control rounded shadow-sm my-auto" style="appearance: none; margin: 0" name="amount" placeholder="Amount">
                                    <button id="add-Product-Send-Btn" type="submit" onclick="submitAddProduct()" class="btn btn-primary shadow rounded-circle">
                                        <i class="fa fa-plus" style="font-size:23px"></i>
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>

        <!-- manage product -->
        <c:if test="${userAccessLevel=='FULL' || userAccessLevel=='PRODUCTS'}">
            <div class="modal" id="productManageModal">
                <div class="modal-dialog modal-dialog-centered" style="max-width: 400px">
                    <div class="modal-content">
                        <div class="modal-header shadow">
                            <i class="fa fa-cog my-auto mr-auto" style="font-size:25px;"></i>
                            <h5 class="modal-title">Manage product in list</h5>
                            <button type="button" class="close" data-dismiss="modal">
                                <span>&times;</span>
                            </button>
                        </div>
                        <div class="modal-body mx-3">
                            <div class="text my-auto mr-2">Change needed amount  (more than purchased)</div>
                            <div id="manage-product-changeProductTotal" class="input-group mb-2 justify-content-center" style="max-width: 300px" onclick="manageProduct('changeProductTotal')">
                                <div class="input-group-prepend">
                                    <span id="manage-product-min" class="input-group-text" style="min-width: 50px">10</span>
                                </div>
                                <form id="manage-product-form" action="${contextPath}restricted/shopping.lists.handler" method="POST">
                                    <input type="hidden" name="list_id" value="${list.id}">
                                    <input id="manage-product-action" type="hidden" name="action">
                                    <input id="manage-product-product_id" type="hidden" name="product_id">
                                    <input type="number" id="manage-product-amount_input" class="form-control text-center rounded shadow-sm my-auto" style="appearance: none" name="amount" min="10" placeholder="10" onkeyup="{
                                                if (this.value < this.min)
                                                    this.value = this.min
                                            }">
                                </form>
                            </div>
                            <button id="manage-product-removeProduct" type="button" class="btn btn-danger shadow-sm mx-auto my-2" onclick="manageProduct('removeProduct')">
                                Remove product
                                <i class="fa fa-trash mr-auto"></i>
                            </button>
                            <button id="manage-product-resetProduct" type="button" class="btn btn-danger shadow-sm mx-auto my-2" onclick="manageProduct('resetProduct')">
                                Reset purchased
                                <i class="fa fa-trash mr-auto"></i>
                            </button>
                        </div>
                        <div class="modal-footer">
                            <button id="manage-product-confirm" type="button" class="btn btn-primary" onclick="$('#manage-product-form')[0].submit()">Confirm<i class="fa fa-check ml-1"></i></button>
                            <button type="button" class="btn btn-danger" data-dismiss="modal">Cancel<i class="fa fa-times ml-1"></i></button>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>

        <div class="modal modal-fluid"id="sendPurchasedModal">
            <div class="modal-dialog modal-dialog-centered modal-sm">
                <div class="modal-content">
                    <div class="modal-header shadow">
                        <h5 class="modal-title">Confirm purchases ?</h5>
                        <button type="button" class="close" data-dismiss="modal">
                            <span>&times;</span>
                        </button>
                    </div>
                    <form id="sendPurchaseForm" action="${contextPath}restricted/shopping.lists.handler" method="POST">
                        <input type="hidden" name="action" value="purchaseProducts">
                        <input type="hidden" name="list_id" value="${list.id}">
                    </form>
                    <div class="modal-footer form-horizontal">
                        <button type="button" class="btn btn-primary" data-dismiss="modal" onclick="sendPurchased()">Confirm</button>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </div>
        </div>

        <footer class="page-footer font-small blue pt-3">
            <hr>
            <div class="p-3 mb-2 bg-dark text-white">
                Follow us on Github: <a href="https://github.com/AndreiDiaconu97/Shopping_Lists"> Shopping_Lists</a>
            </div>
        </footer>

        <script>
            // spoiler setup
            $(document).on('click', '.panel div.clickable', function (e) {
                var $this = $(this); //Heading
                var $panel = $this.parent('.panel');
                var $panel_body = $panel.children('.panel-body');
                var $display = $panel_body.css('display');

                if ($display === 'block') {
                    $panel_body.slideUp();
                } else if ($display === 'none') {
                    $panel_body.slideDown();
                }
            });
            $(document).ready(function (e) {
                var $classy = '.panel.autocollapse';

                var $found = $($classy);
                $found.find('.panel-body').hide();
                $found.removeClass($classy);
            });

            function intervalClick(button, operator) {
                let interval = setInterval(() => {
                    changeValue(button, operator, interval);
                    console.log('interval trigger');
                }, 300);
                changeValue(button, operator, interval);
                console.log('interval started');
                button.onmouseup = () => {
                    console.log('mouseup');
                    clearInterval(interval);
                };
            }

            // in/decrement buttons
            function changeValue(button, operator, interval) {
                var btnID = button.id.match(/\d+/g);
                var btnName = button.id.match(new RegExp("[(left)|(right)]+" + "(.*)" + btnID))[1];
                var inputName = btnName.match(new RegExp("Btn" + "(.*)"))[1];
                var prodAmount = document.getElementById('prodAmount' + inputName + btnID);

                var value = parseInt(prodAmount.value);
                value = isNaN(value) ? prodAmount.min : value;

                var maxVal = parseInt(prodAmount.max);
                var minVal = parseInt(prodAmount.min);
                switch (operator) {
                    case '+':
                        document.getElementById('left' + btnName + btnID).disabled = false;
                        if (maxVal) {
                            if (value < maxVal) {
                                value++;
                                if (value === maxVal) {
                                    clearInterval(interval);
                                    button.disabled = true;
                                }
                            }
                        } else {
                            value++;
                        }
                        break;
                    case '-':
                        document.getElementById('right' + btnName + btnID).disabled = false;
                        if (value > minVal) {
                            value--;
                            if (value === minVal) {
                                clearInterval(interval);
                                button.disabled = true;
                            }
                        }
                        break;
                }
                prodAmount.value = value;
            }

            // product input range limiter
            function handleChange(input, id) {
                if (!input.value) {
                    return;
                }
                if (input.value < parseInt(input.min)) {
                    input.value = input.min;
                }
                if (input.value > parseInt(input.max)) {
                    input.value = input.max;
                }
                if (input.value !== input.max) {
                    $('#rightBtn' + id)[0].disabled = false;
                } else {
                    $('#rightBtn' + id)[0].disabled = true;
                }
                if (input.value !== input.min) {
                    $('#leftBtn' + id)[0].disabled = false;
                } else {
                    $('#leftBtn' + id)[0].disabled = true;
                }
            }

            var listProducts = ${ listProductsJSON };
            var userAccessLevel = "${userAccessLevel}";

            // show products
            function showProducts() {
                let sortby = $('#p-search-sort')[0].value;
                let pcatID = $('#p-search-cat')[0].value;
                let name = $('#p-search-name')[0].value;
                let products = listProducts.slice();
                if (pcatID !== "-1") {
                    products = products.filter(p => p.category.id.toString() === pcatID);
                }
                products = products.filter(p => p.name.toUpperCase().includes(name.toUpperCase()));
                switch (sortby) {
                    case "Rating":
                        products.sort((l, r) => l.rating < r.rating ? 1 : -1);
                        break;

                    case "Popularity":
                        // already ordered
                        break;

                    default:
                        // Name
                        products.sort((l, r) => l.name > r.name ? 1 : -1);
                        break;
                }

                let missing = products.filter(p => p.purchased !== p.total);
                let missinghtml = "";
                for (p of missing) {
                    let day = 24 * 3600 * 1000;
                    let need_reset = (new Date(p.last_purchase) + day * p.category.renew_time) < new Date();
                    missinghtml = missinghtml
                            + '<div class="card shadow-sm mb-2">'
                            + '    <div class="card-body">'
                            + '        <div class="row">'
                            + '            <img class="img-fluid img-thumbnail rounded mx-2" style="min-width: 50px; min-height: 100%; max-width: 100%; max-height: 60px"  alt="Responsive image" src="../images/products/' + p.id + '">'
                            + '            <div class="text-left my-auto">'
                            + '                ' + p.name
                            + '            </div>'
                            + '            <div class="row ml-auto my-auto mx-1 pt-2">'
                            + '                <div id="input-group-edit-product' + p.id + '" class="input-group" style="width: 300px">';
                    if (userAccessLevel == "FULL" || userAccessLevel == "PRODUCTS") {
                        missinghtml = missinghtml
                                + (need_reset ? (' <label class="input-group-text ml-auto" for="input-group-edit-product' + p.id + '" style="background-color: #F1C40F" data-toggle="tooltip" data-placement="top" title="It\'s been a while.\nReset suggested">'
                                        + '                    <i class="fas fa-exclamation-triangle" style="font-size: 28px"></i>'
                                        + '                </label>') : '')
                                + '                <button type="button" id="modifyProdBtn' + p.id + '" class="btn btn-info btn-sm shadow-sm ' + (need_reset ? '' : 'ml-auto') + ' mr-2" data-toggle="modal" data-target="#productManageModal" onclick="fillProductManageModal(' + p.id + ')">'
                                + '                   <i class="fa fa-edit mr-auto" style="font-size: 28px"></i>'
                                + '                </button>';
                    }
                    missinghtml = missinghtml
                            + '                    <button type="button" id="leftBtn' + p.id + '" class="btn btn-secondary btn-sq-sm shadow-sm" disabled onmousedown="intervalClick(this,\'-\')">'
                            + '                        <i class="fa fa-chevron-left mr-auto"></i>'
                            + '                    </button>'
                            + '                    <input type="number" id="prodAmount' + p.id + '" class="form-control text-center rounded shadow-sm my-auto" style="appearance: none; margin: 0"  name="quantity" min="' + p.purchased + '" max="' + p.total + '" value="' + p.purchased + '" placeholder="' + p.purchased + '" oninput="handleChange(this,' + p.id + ')"><br>'
                            + '                        <span class="input-group-text" id="basic-addon2">' + p.total + '</span>'
                            + '                    <button type="button" id="rightBtn' + p.id + '" class="btn btn-secondary btn-sq-sm shadow-sm" onmousedown="intervalClick(this, \'+\')">'
                            + '                        <i class="fa fa-chevron-right mr-auto"></i>'
                            + '                    </button>'
                            + '                </div>'
                            + '            </div>'
                            + '        </div>'
                            + '    </div>'
                            + '</div>';
                }
                $('#missing-products')[0].innerHTML = missinghtml;


                let purchased = products.filter(p => p.purchased === p.total);
                let purchasedhtml = "";
                for (p of purchased) {
                    let day = 24 * 3600 * 1000;
                    let need_reset = (new Date(p.last_purchase) + day * p.category.renew_time) < new Date();
                    purchasedhtml = purchasedhtml
                            + '<div class="card shadow-sm mb-2" style="background-color: whitesmoke">'
                            + '    <div class="card-body">'
                            + '        <div class="row">'
                            + '            <img class="img-fluid img-thumbnail rounded mx-2" style="min-width: 50px; min-height: 100%; max-width: 100%; max-height: 60px"  alt="Responsive image" src="../images/products/' + p.id + '">'
                            + '            <div class="text-left my-auto">'
                            + '                ' + p.name
                            + '            </div>'
                            + '            <div class="row ml-auto my-auto mx-1 pt-2">'
                            + '                <div id="input-group-edit-product' + p.id + '" class="input-group" style="width: 300px">';
                    if (userAccessLevel == "FULL" || userAccessLevel == "PRODUCTS") {
                        purchasedhtml = purchasedhtml
                                + (need_reset ? (' <label class="input-group-text ml-auto" for="input-group-edit-product' + p.id + '" style="background-color: #F1C40F" data-toggle="tooltip" data-placement="top" title="It\'s been a while.\nReset suggested">'
                                        + '                    <i class="fas fa-exclamation-triangle" style="font-size: 28px"></i>'
                                        + '                </label>') : '')
                                + '                <button type="button" id="modifyProdBtn' + p.id + '" class="btn btn-info btn-sm shadow-sm ' + (need_reset ? '' : 'ml-auto') + '" data-toggle="modal" data-target="#productManageModal" onclick="fillProductManageModal(' + p.id + ')">'
                                + '                   <i class="fa fa-edit mr-auto" style="font-size: 28px"></i>'
                                + '                </button>';
                    }
                    purchasedhtml = purchasedhtml
                            + '                </div>'
                            + '            </div>'
                            + '        </div>'
                            + '    </div>'
                            + '</div>';
                }
                $('#purchased-products')[0].innerHTML = purchasedhtml;
            }

            showProducts();

            function scrollChat() {
                setTimeout(() => {
                    var objDiv = document.getElementById("chatbody");
                    objDiv.scrollTop = objDiv.scrollHeight;
                }, 10);
            }

            var otherProducts = ${otherProductsJSON};
            function fillProductsAddModal() {
                let sortby = $('#p-add-sort')[0].value;
                let pcatID = $('#p-add-cat')[0].value;
                let name = $('#p-add-name')[0].value;
                let products = otherProducts.slice();
                if (pcatID !== "-1") {
                    products = products.filter(p => p.category.id.toString() === pcatID);
                }
                products = products.filter(p => p.name.toUpperCase().includes(name.toUpperCase()));
                switch (sortby) {
                    case "Rating":
                        products.sort((l, r) => l.rating < r.rating ? 1 : -1);
                        break;

                    case "Popularity":
                        // already ordered
                        break;

                    default:
                        // Name
                        products.sort((l, r) => l.name > r.name ? 1 : -1);
                        break;
                }

                let innerhtml = "";
                for (p of products) {
                    innerhtml = innerhtml
                            + '<div id="add-product-div-' + p.id + '" class="container-fluid rounded shadow border mb-2" style="background-color: whitesmoke" onclick="selectAddProduct(' + p.id + ')">'
                            + '          <div class="row my-2 ml-0">'
                            + '              <img class="img-thumbnail mx-auto my-auto" style="width: 80px; height: 100%; min-width: 50px; min-height: 100%" alt="Responsive image" src="../images/products/' + p.id + '">'
                            + '              <div class="col my-auto">'
                            + '                  <div class="text-left" style="font-size: 18px">'
                            + '                      ' + p.name
                            + '                  </div>'
                            + '              </div>'
                            + '          </div>'
                            + '          <div class="row mx-0 justify-content-between">'
                            + '              <div class="row mx-0 my-auto">'
                            + '                  <div class="input-group mb-3 my-auto" data-toggle="tooltip" data-placement="top" title="Rating: ' + p.rating.toString().substr(0, 3) + '">'
                            + '                      <i class="' + (p.rating >= 0.8 ? 'fas fa-star' : (p.rating >= 0.3 ? 'fa fa-star-half-alt' : 'far fa-star')) + '" style="font-size:21px;"></i>'
                            + '                      <i class="' + (p.num_votes > 0 ? (p.rating >= 1.8 ? 'fas fa-star' : (p.rating >= 1.3 ? 'fa fa-star-half-alt' : 'far fa-star')) : 'far fa-question-circle') + '" style="font-size:21px;"></i>'
                            + '                      <i class="' + (p.rating >= 2.8 ? 'fas fa-star' : (p.rating >= 2.3 ? 'fa fa-star-half-alt' : 'far fa-star')) + '" style="font-size:21px;"></i>'
                            + '                      <i class="' + (p.num_votes > 0 ? (p.rating >= 3.8 ? 'fas fa-star' : (p.rating >= 3.3 ? 'fa fa-star-half-alt' : 'far fa-star')) : 'far fa-question-circle') + '" style="font-size:21px;"></i>'
                            + '                      <i class="' + (p.rating >= 4.8 ? 'fas fa-star' : (p.rating >= 4.3 ? 'fa fa-star-half-alt' : 'far fa-star')) + '" style="font-size:21px;"></i>'
                            + '                  </div>'
                            + '              </div>'
                            + '              <div class="badge badge-pill badge-secondary shadow my-auto">' + p.category.name + '</div>'
                            + '              <div class="text-left">Votes: ' + p.num_votes + '</div>'
                            + '          </div>'
                            + '          <hr>'
                            + '          <div class="panel panel-success autocollapse">'
                            + '              <div class="panel-heading clickable">'
                            + '                  <div class="row mx-auto">'
                            + '                      <p>Description</p>'
                            + '                      <i class="fa fa-chevron-circle-down ml-2" style="font-size:25px;"></i>'
                            + '                      <div class="text ml-auto mr-2" style="color: grey">created by</div>'
                            + '                      <div class="text" style="font-size: 18px">' + p.creator.firstname + ' ' + p.creator.lastname + '</div>'
                            + '                  </div>'
                            + '              </div>'
                            + '              <div class="panel-body">'
                            + '                  <div class="text-justify mx-4 mb-4">'
                            + '                      ' + p.description
                            + '                  </div>'
                            + '              </div>'
                            + '          </div>'
                            + '      </div>';
                }
                $('#otherProducts')[0].innerHTML = innerhtml;
            }
            fillProductsAddModal();

            function resetPurchased() {
                let missing = listProducts.filter(p => p.purchased !== p.total);
                for (p of missing) {
                    $('#leftBtn' + p.id)[0].disabled = true;
                    $('#rightBtn' + p.id)[0].disabled = false;
                    $('#prodAmount' + p.id)[0].value = p.purchased;
                }
            }

            var selectedProduct = -1;
            $('#add-Product-Send-Btn')[0].disabled = true;
            function selectAddProduct(id) {
                if (selectedProduct != -1) {
                    $('#add-product-div-' + selectedProduct)[0].style['background-color'] = "whitesmoke";
                }
                $('#add-Product-Send-Btn')[0].disabled = false;
                selectedProduct = id;
                $('#add-product-div-' + id)[0].style['background-color'] = "#5DADE2";
            }

            function submitAddProduct() {
                if (selectedProduct != -1 && $('#add-Product-Form-Amount')[0].value) {
                    $('#add-Product-Hidden-Id')[0].value = selectedProduct;
                    $('#add-Product-Form')[0].submit();
                }
            }

            function fillProductManageModal(id) {
                let product = listProducts.filter(p => p.id == id)[0];
                $('#manage-product-changeProductTotal')[0].style.border = "";
                $('#manage-product-removeProduct')[0].style.border = "";
                $('#manage-product-resetProduct')[0].style.border = "";
                $('#manage-product-confirm')[0].deactivated = true;
                $('#manage-product-product_id')[0].value = product.id;
                $('#manage-product-min')[0].innerHTML = product.purchased;
                $('#manage-product-amount_input')[0].min = product.purchased;
                $('#manage-product-amount_input')[0].placeholder = product.total;
                $('#manage-product-amount_input')[0].value = product.total;
            }

            $('#manage-product-confirm')[0].deactivated = true;
            function manageProduct(item) {
                $('#manage-product-action')[0].value = item;
                $('#manage-product-changeProductTotal')[0].style.border = "";
                $('#manage-product-removeProduct')[0].style.border = "";
                $('#manage-product-resetProduct')[0].style.border = "";
                $('#manage-product-' + item)[0].style.border = "3px solid blue";
                $('#manage-product-confirm')[0].deactivated = false;
            }

            function sendPurchased() {
                let missing = listProducts.filter(p => p.purchased !== p.total);
                let changed = missing.filter(p => $('#prodAmount' + p.id)[0].value !== p.purchased.toString());
                let inputs = "";
                for (p of changed) {
                    console.log('Changed ' + p.name);
                    inputs += '<input type="hidden" name="product_id" value="' + p.id + '">';
                    inputs += '<input type="hidden" name="purchased_' + p.id + '" value="' + $('#prodAmount' + p.id)[0].value + '">';
                }
                $('#sendPurchaseForm')[0].innerHTML += inputs;
                $('#sendPurchaseForm')[0].submit();
            }
        </script>
    </body>

</html>