<%@page import="db.daos.jdbc.JDBC_utility"%>
<%@page import="db.daos.jdbc.JDBC_utility.AccessLevel"%>
<%@page import="java.util.Arrays"%>
<%@page import="db.daos.List_categoryDAO"%>
<%@page import="db.daos.UserDAO"%>
<%@page import="db.entities.List_category"%>
<%@page import="db.entities.List_reg"%>
<%@page import="java.util.List"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
            throw new RuntimeException(new ServletException("Impossible to get the dao for shop_list", ex));
        }
        try {
            list_catDao = daoFactory.getDAO(List_categoryDAO.class);
        } catch (DAOFactoryException ex) {
            throw new RuntimeException(new ServletException("Impossible to get the dao for list_cat", ex));
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
    if (response.isCommitted()) {
        getServletContext().log("shopping.list.html is already committed");
    }

    String contextPath = getServletContext().getContextPath();
    if (!contextPath.endsWith("/")) {
        contextPath += "/";
    }

    // check user
    User user = null;
    if (session != null) {
        user = (User) session.getAttribute("user");
    }
    if (user == null) {
        if (!response.isCommitted()) {
            response.sendRedirect(response.encodeRedirectURL(contextPath + "login.html"));
        }
    }

    // check shopping list
    String shop_list_Param = request.getParameter("shop_listID");
    if ((shop_list_Param == null) || (shop_list_Param.equals(""))) {
        if (!response.isCommitted()) {
            response.sendRedirect(response.encodeRedirectURL(contextPath + "restricted/homepage.html"));
        }
        return;
    }
    Integer shop_list_ID = Integer.parseInt(shop_list_Param);

    // retrieve list
    List_reg shopping_list = null;
    try {
        shopping_list = list_regDao.getByPrimaryKey(shop_list_ID);
        pageContext.setAttribute("shopping_list", shopping_list);
    } catch (DAOException ex) {
        System.err.println("Error retrieving shopping lists (jsp)" + ex);
        if (!response.isCommitted()) {
            response.sendRedirect(contextPath + "error.html?error=");
        }
    }
    if (shopping_list == null) {
        if (!response.isCommitted()) {
            response.sendRedirect(response.encodeRedirectURL(contextPath + "restricted/homepage.html"));
        }
        return;
    }

    //check visibility
    if ((user.getId() != shopping_list.getOwner().getId()) && !(list_regDao.getUsersSharedTo(shopping_list)).contains(user)) {
        if (!response.isCommitted()) {
            response.sendRedirect(response.encodeRedirectURL(contextPath + "restricted/homepage.html"));
        }
        return;
    }

    List<User> shared_to = list_regDao.getUsersSharedTo(shopping_list);
    boolean isListOwner = (user.getId() == shopping_list.getOwner().getId());
    pageContext.setAttribute("shared_to", shared_to);
    pageContext.setAttribute("isListOwner", isListOwner);
    pageContext.setAttribute("userDao", userDao);
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Shopping lists manager</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" charset="UTF-8">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

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
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarSupportedContent">
                <ul class="nav navbar-nav ml-auto">
                    <li class="dropdown ml-auto my-auto">
                        <div class="text-white mx-2">logged in as <b>${user.email}</b></div>
                    </li>                    
                    <li class="dropdown ml-auto my-auto">
                        <form class="form-inline" action="<%=contextPath%>auth" method="POST" method="POST">
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
                    <img class="img-fluid rounded shadow mx-auto" alt="Responsive image" src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Logo-Free.jpg">
                </div>
                <div class="row">
                    <div class="my-auto mr-2" style="text-shadow: 2px 2px 8px #bbbbbb;">
                        <h2><c:out value="${shopping_list.name}"/></h2>
                    </div>
                    <h4>
                        <small>
                            <span class="badge badge-pill badge-secondary shadow mr-2">
                                <c:out value="${shopping_list.category.name}"/>
                            </span>
                        </small>
                    </h4>
                    <c:if test="${isListOwner}">
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
                        <c:out value="${shopping_list.owner.firstname} ${shopping_list.owner.lastname}"/>
                    </span>  
                    <span style="color: gray; font-size: 10pt">
                        <c:out value="(${shopping_list.owner.email})"/>
                    </span>  
                </p>
                <button type="button" class="btn btn-dark btn-sm mx-1 ml-auto" href="#chatModal" data-toggle="modal">
                    <i class="fa fa-comments" style="font-size:30px; color: graytext"></i>
                </button>
                <button type="button" class="btn btn-dark btn-sm mx-1" href="#participantsModal" data-toggle="modal">
                    <i class="fa fa-users" style="font-size:30px; color: graytext"></i>
                </button>
                <button type="button" class="btn btn-dark btn-sm mx-1" href="#shareModal" data-toggle="modal">
                    <i class="fa fa-share-alt" style="font-size:30px; color: graytext"></i>
                </button>
            </div>
        </div>

        <!-- description spoiler -->
        <div class="container-fluid mb-4">
            <div class="panel panel-success autocollapse">
                <div class="panel-heading clickable">
                    <div class="row mx-auto">
                        <i class="fa fa-chevron-circle-down mr-2 my-auto" style="font-size:20px;"></i>
                        <div class="text-left my-auto">Description</div>
                    </div>
                    <hr>
                </div>
                <div class="panel-body">
                    <div class="text-justify mx-4">
                        <c:out value="(${shopping_list.description})"/>
                    </div>
                </div>
            </div>
        </div>

        <!-- products -->
        <div class="card mb-2 shadow border-0">
            <div class="card-header">
                <div class="row my-auto mx-1">
                    <h4 class="my-auto pb-2">Products <small><span class="badge badge-secondary shadow">3/7</span></small></h4>
                    <div class="row ml-auto">
                        <div class="input-group">
                            <input class="form-control" type="search" placeholder="Search products in list..." aria-label="Search">
                            <button class="btn btn-outline-success" type="submit">
                                <i class="fa fa-search mr-auto"></i>
                            </button>   
                            <button type="button" class="btn btn-primary ml-2 my-auto shadow rounded-circle" href="#addProductModal" data-toggle="modal">          
                                <i class="fa fa-plus mr-auto"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="container-fluid">
            <div class="row mx-auto mb-2 justify-content-end">
                <button type="button" class="btn btn-success mr-2 my-auto shadow rounded border" href="#">  
                    Update
                    <i class="fa fa-check ml-1"></i>
                </button>
                <button type="button" class="btn btn-danger my-auto shadow rounded" href="#">  
                    Cancel
                    <i class="fa fa-times ml-1"></i>
                </button>
            </div>
            <c:forEach var = "i" begin="0" end="20">
                <div class="card shadow-sm mb-2">
                    <div class="card-body">
                        <div class="row">
                            <img class="img-fluid img-thumbnail rounded mx-2" style="min-width: 50px; min-height: 100%; max-width: 100%; max-height: 60px"  alt="Responsive image" src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Logo-Free.jpg">
                            <div class="text-left my-auto">
                                product ${i}
                            </div>
                            <div class="row ml-auto my-auto mr-1 pt-2">
                                <div class="input-group">
                                    <c:if test="${isListOwner}">
                                        <button type="button" id="modifyProdBtn${i}" class="btn btn-info btn-sm shadow-sm mr-2" data-toggle="modal" data-target="#productManageModal" onclick="prodManageModalHandler()">
                                            <i class="fa fa-edit mr-auto" style="font-size: 28px"></i>
                                        </button>
                                    </c:if>
                                    <button type="button" id="leftBtn${i}" class="btn btn-secondary btn-sq-sm shadow-sm"disabled onclick="changeValue(this, '-')">
                                        <i class="fa fa-chevron-left mr-auto"></i>
                                    </button>
                                    <input type="number" id="prodAmount${i}" class="form-control rounded shadow-sm my-auto" style="appearance: none; margin: 0"  name="quantity" min="3" max="10" value="3" placeholder="3" oninput="handleChange(this)"><br>
                                    <div class="input-group-append">
                                        <span class="input-group-text" id="basic-addon2">10</span>
                                    </div>
                                    <button type="button" id="rightBtn${i}" class="btn btn-secondary btn-sq-sm shadow-sm" onclick="changeValue(this, '+')">
                                        <i class="fa fa-chevron-right mr-auto"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
            <div class="row mx-auto mb-2 justify-content-end">
                <button type="button" class="btn btn-success mr-2 my-auto shadow rounded" href="#">  
                    Update
                    <i class="fa fa-check ml-1"></i>
                </button>
                <button type="button" class="btn btn-danger my-auto shadow rounded" href="#">  
                    Cancel
                    <i class="fa fa-times ml-1"></i>
                </button>
            </div>
            <c:forEach var = "i" begin="0" end="20">
                <div class="card shadow-sm mb-2" style="background-color: whitesmoke">
                    <div class="card-body">
                        <div class="row">
                            <img class="img-fluid img-thumbnail rounded mx-2" style="min-width: 50px; min-height: 100%; max-width: 100%; max-height: 60px"  alt="Responsive image" src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Logo-Free.jpg">
                            <div class="text-left my-auto">
                                product ${i}
                            </div>
                            <div class="row ml-auto my-auto mr-4 pt-2">
                                <i class="fa fa-minus mr-auto"></i>
                            </div>
                        </div
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
    <!-- MODALS -->

    <!-- list settings -->
    <c:if test="${isListOwner}">
        <div class="modal modal-fluid" id="listSettingsModal" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header shadow">
                        <i class="fa fa-cog my-auto mr-auto" style="font-size:25px;"></i>
                        <h5 class="modal-title">Shopping list edit</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body mx-3">
                        <div class="md-form mb-3">
                            <i class="fa fa-image prefix grey-text"></i>
                            <label data-error="error" data-success="success" for="defaultForm-email">Logo</label>
                            <div class="custom-file">
                                <input type="file" class="custom-file-input" id="inputGroupFile01" aria-describedby="inputGroupFileAddon01">
                                <label class="custom-file-label" for="inputGroupFile01">Choose file</label>
                            </div>
                        </div>
                        <div class="md-form mb-3">
                            <i class="fa fa-bookmark prefix grey-text"></i>
                            <label data-error="error" data-success="success" for="defaultForm-email">List name</label>
                            <input type="text" class="form-control validate"/>
                        </div>
                        <div class="md-form mb-3">
                            <i class="fa fa-align-left prefix grey-text"></i>
                            <label data-error="error" data-success="success" for="defaultForm-email">Description</label>
                            <textarea class="form-control validate"></textarea>
                        </div>
                        <div class="input-group">
                            <select class="form-control">
                                <option value="volvo" selected>Volvo</option>
                                <option value="saab">Saab</option>
                                <option value="mercedes">Mercedes</option>
                                <option value="audi">Audi</option>
                            </select>
                            <div class="input-group-append">
                                <span class="input-group-text">Category</span>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-primary">Confirm<i class="fa fa-check ml-1"></i></button> 
                        <button type="button" class="btn btn-danger" data-dismiss="modal">Cancel<i class="fa fa-times ml-1"></i></button>
                    </div>
                </div>
            </div>
        </div>
    </c:if>

    <!-- chat -->
    <div class="modal modal-fluid" id="chatModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header shadow">
                    <i class="fa fa-comments my-auto mr-auto" style="font-size:30px;"></i>
                    <h5 class="modal-title">Group chat</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body" style="height:72vh; overflow-y:scroll; width: 100%" >
                    <c:forEach var="i" begin="0" end="15">
                        <div class="row mb-2 ml-0">
                            <div class="col-3 col-md-2">
                                <div class="row">
                                    <img class="img-thumbnail shadow-sm" style="width: 100px; height: 100%; min-width: 50px; min-height: 100%" alt="Responsive image" src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Logo-Free.jpg">
                                </div>
                                <div class="row">
                                    User${i} can be a very long name too  
                                </div>
                            </div>
                            <div class="col">
                                message${i} an be a very lon one sads asd saas dasd asd sasd asd wda awwad aw awaw dw aw awwad waddaw wad
                            </div>
                        </div>
                        <hr>
                    </c:forEach>
                </div>
                <div class="modal-footer form-horizontal">
                    <input class="form-control mr-2" type="text" style="width: 92%" placeholder="write a message..." aria-label="write a message...">
                    <button type="submit" class="btn btn-secondary"><i class="fa fa-arrow-circle-right my-auto" style="font-size:23px;"></i></button>
                </div>
            </div>
        </div>
    </div>

    <!-- participants -->
    <div class="modal modal-fluid" id="participantsModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header shadow">
                    <i class="fa fa-users my-auto mr-auto" style="font-size:30px;"></i>
                    <h5 class="modal-title">Participants</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body" style="height:72vh; overflow-y:scroll; width: 100%" >
                    <%
                        for (User shared_user : list_regDao.getUsersSharedTo(shopping_list)) {
                            AccessLevel uAccessLevel = userDao.getAccessLevel(shared_user, shopping_list);
                            pageContext.setAttribute("access_levels", AccessLevel.values());
                            pageContext.setAttribute("uAccessLevel", uAccessLevel);
                    %>
                    <div class="row mb-2 px-auto ml-0">
                        <img class="img-thumbnail shadow-sm mr-2" style="width: 70px; height: 100%; min-width: 50px; min-height: 100%" alt="Responsive image" src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Logo-Free.jpg">
                        <p class="mr-2 my-auto">
                            <c:out value="${user.firstname} ${user.lastname}"/>
                        </p>
                        <p class="mr-2 my-auto" style="color: grey">
                            <c:out value="(${user.email})"/> 
                        </p>
                        <div class="row ml-auto mx-2 my-2">
                            <div class="input-group my-auto">
                                <select class="custom-select" id="inputGroupSelect02">
                                    <c:forEach var="access_level" varStatus="i" items="${access_levels}">
                                        <option value="${i.index}" <c:if test="${access_level == uAccessLevel}">selected</c:if>>${access_level}</option>
                                    </c:forEach>
                                </select>
                                <div class="input-group-append">
                                    <label class="input-group-text" for="inputGroupSelect02">
                                        <i class="fa fa-wrench"></i>
                                    </label>
                                </div>
                            </div>
                        </div>
                        <button type="button" class="btn btn-danger my-auto mr-2 shadow-sm rounded" data-toggle="button" aria-pressed="false">
                            <i class="fa fa-user-times" style="font-size:25px"></i>
                        </button>
                    </div>
                    <hr>
                    <%                        }
                    %>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" data-dismiss="modal">Confirm changes</button> 
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </div>

    <!-- share -->
    <div class="modal modal-fluid" id="shareModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header shadow">
                    <i class="fa fa-share-alt my-auto mr-auto" style="font-size:30px;"></i>
                    <h5 class="modal-title ml-2">Share your shopping list</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <!-- BEWARE! following jtsl are only temporary templates -->
                <div class="modal-body" style="height:72vh; overflow-y:scroll; width: 100%" >
                    <c:forEach var="user_sharing" varStatus="i" begin="0" end="10">
                        <div class="row px-auto ml-0">
                            <img class="img-thumbnail shadow-sm mr-2 mb-2" style="width: 70px; height: 100%; min-width: 50px; min-height: 100%" alt="Responsive image" src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Logo-Free.jpg">
                            <p class="mr-2 my-auto">
                                <c:out value="firstname lastname"/>
                            </p>
                            <p class="mr-2 my-auto" style="color: grey">
                                <c:out value="(email)"/> 
                            </p>
                            <div class="row ml-auto mx-2 my-2">
                                <div class="input-group my-auto">
                                    <select class="custom-select" id="sharePermssionsSelect${i.index}">
                                        <%
                                            pageContext.setAttribute("access_levels", AccessLevel.values());
                                        %>
                                        <c:forEach var="access_level" varStatus="i" items="${access_levels}">
                                            <option value="${i.index}" <c:if test="${i.index == 0}">selected</c:if>>${access_level}</option>
                                        </c:forEach>
                                    </select>
                                    <div class="input-group-append">
                                        <label class="input-group-text" for="sharePermssionsSelect${i.index}">
                                            <i class="fa fa-wrench"></i>
                                        </label>
                                    </div>
                                </div>
                            </div>
                            <button type="button" class="btn btn-success my-auto mr-2 shadow-sm rounded" data-toggle="button" aria-pressed="false">
                                <i class="fa fa-user-plus" style="font-size:25px"></i>
                            </button>
                            <button type="button" class="btn btn-info my-auto mr-2 shadow-sm rounded" data-toggle="button" aria-pressed="false">
                                <i class="fa fa-clipboard" style="font-size:20px"></i>
                            </button>
                        </div>
                        <hr>
                    </c:forEach>
                </div>
                <div class="modal-footer">
                    <input class="form-control mr-2" type="text" style="width: 92%" placeholder="insert user name..." aria-label="insert user name...">
                    <button type="submit" class="btn btn-secondary">
                        <i class="fa fa-search my-auto" style="font-size:23px;"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- add product -->
    <div class="modal modal-fluid" id="addProductModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header shadow">
                    <i class="fa fa-cart-plus my-auto mr-auto" style="font-size:30px;"></i>
                    <h5 class="modal-title">Add product to list</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body" style="height:72vh; overflow-y:scroll; width: 100%" >
                    <c:forEach var="i" begin="0" end="15">
                        <div class="container-fluid rounded shadow border mb-2" style="background-color: whitesmoke">
                            <div class="row my-2 ml-0">
                                <img class="img-thumbnail mx-auto my-auto" style="width: 100px; height: 100%; min-width: 50px; min-height: 100%" alt="Responsive image" src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Logo-Free.jpg">
                                <div class="col my-auto">
                                    <div class="text-left">
                                        Product${i} can be a very long name too rterg ge gr egg reg er eer er rer ege er erer er
                                    </div>  
                                </div>
                            </div>
                            <div class="row mx-0 justify-content-between">
                                <div class="row mx-0 my-auto">
                                    <div class="input-group mb-3 my-auto">
                                        <c:forEach var="i" begin="0" end="3">
                                            <i class="fa fa-star" style="font-size:21px;"></i>
                                        </c:forEach>
                                        <i class="fa fa-star-o" style="font-size:21px;"></i>
                                    </div>
                                </div>
                                <div class="badge badge-pill badge-secondary shadow my-auto">Category</div>
                                <div class="text-left">31212242 ratings</div>  
                            </div>
                            <hr>
                            <div class="panel panel-success autocollapse">
                                <div class="panel-heading clickable">
                                    <div class="row mx-auto">
                                        <p>Description</p>
                                        <i class="fa fa-chevron-circle-down ml-2" style="font-size:25px;"></i>
                                        <div class="text ml-auto mr-2" style="color: grey">created by</div>
                                        <div class="text" style="font-size: 18px">Author</div>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="text-justify mx-4 mb-4">
                                        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus eget ante sed nisl semper bibendum vel id quam. Maecenas aliquam urna suscipit, posuere leo eu, efficitur arcu. Phasellus convallis vel odio vitae viverra. Quisque a ipsum sem. Duis interdum finibus iaculis. Nam metus eros, accumsan suscipit erat malesuada, dictum ullamcorper purus. Aliquam viverra imperdiet hendrerit. Maecenas condimentum massa non lectus elementum vestibulum. Nunc sodales nisl ullamcorper diam porta varius. Nam viverra feugiat malesuada. Vivamus mollis lectus quis metus egestas, eu molestie erat rutrum. Aliquam congue nisi sit amet mauris rhoncus, sed finibus nisi vulputate. Etiam at rhoncus justo.
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
                <div class="modal-footer form-horizontal">
                    <div class="input-group my-auto mx-auto">
                        <select class="custom-select" style="min-width: 90px">
                            <option value="-1" selected>sort by</option>
                            <option value="0">name [a-Z]</option>
                            <option value="1">name [Z-a]</option>
                        </select>
                        <select class="custom-select" style="min-width: 135px">
                            <option value="-1" selected>all categories</option>
                            <option value="0">category 1</option>
                            <option value="1">category 2</option>
                        </select>
                    </div>
                    <div class="input-group my-auto">
                        <input class="form-control mr-2 my-1" style="min-width: 90px" type="text" placeholder="insert product name..." aria-label="insert product name...">
                        <button type="submit" class="btn btn-secondary mx-auto">
                            <i class="fa fa-search my-auto" style="font-size:23px;"></i>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- manage product -->
    <c:if test="${isListOwner}">
        <div class="modal modal-fluid" id="productManageModal" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header shadow">
                        <i class="fa fa-cog my-auto mr-auto" style="font-size:25px;"></i>
                        <h5 class="modal-title" >Manage product in list</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body mx-3">
                        <div class="input-group">
                            <div class="text my-auto mr-2">Increase product amount</div>
                            <button type="button" id="leftBtnManage0" class="btn btn-secondary btn-sq-sm shadow-sm" disabled onclick="changeValue(this, '-')">
                                <i class="fa fa-chevron-left mr-auto"></i>
                            </button>
                            <div class="input-group-prepend">
                                <span class="input-group-text" id='prodMngMinVal-label'>10</span>
                            </div>
                            <input type="number" id="prodAmountManage0" class="form-control rounded shadow-sm my-auto" style="appearance: none; margin: 0"  name="quantity" min="10" value="10" placeholder="10" oninput="handleChange(this)"><br>
                            <button type="button" id="rightBtnManage0" class="btn btn-secondary btn-sq-sm shadow-sm" onclick="changeValue(this, '+')">
                                <i class="fa fa-chevron-right mr-auto"></i>
                            </button>
                            <button type="button" class="btn btn-danger shadow-sm ml-3">
                                Remove product
                                <i class="fa fa-trash mr-auto"></i>
                            </button>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-primary">Confirm<i class="fa fa-check ml-1"></i></button> 
                        <button type="button" class="btn btn-danger" data-dismiss="modal">Cancel<i class="fa fa-times ml-1"></i></button>
                    </div>
                </div>
            </div>
        </div>
    </c:if>

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

        // in/decrement buttons
        function changeValue(button, operator) {
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
                    if (value === minVal) {
                        document.getElementById('left' + btnName + btnID).disabled = false;
                    }
                    if (maxVal) {
                        if (value < maxVal) {
                            value++;
                            if (value === maxVal) {
                                button.disabled = true;
                            }
                        }
                    } else {
                        value++;
                    }
                    break;
                case '-':
                    if (value === maxVal) {
                        document.getElementById('right' + btnName + btnID).disabled = false;
                    }
                    if (value > minVal) {
                        value--;
                        if (value === minVal) {
                            button.disabled = true;
                        }
                    }
                    break;
            }
            prodAmount.value = value;
        }

        // product input range limiter
        function handleChange(input) {
            if (!input.value) {
                return;
            }
            if (input.value < parseInt(input.min)) {
                input.value = input.min;
            }
            if (input.value > parseInt(input.max)) {
                input.value = input.max;
            }
        }

        // product manage modal handler
        <c:if test="${isListOwner}">
        function prodManageModalHandler() {
        }
        </c:if>
    </script>
</body>
</html>

