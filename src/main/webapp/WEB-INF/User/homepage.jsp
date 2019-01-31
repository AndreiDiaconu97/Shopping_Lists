<%@page import="db.daos.jdbc.JDBC_utility.SortBy"%>
<%@page import="db.daos.ProductDAO"%>
<%@page import="db.entities.Prod_category"%>
<%@page import="db.daos.List_categoryDAO"%>
<%@page import="db.daos.UserDAO"%>
<%@page import="db.entities.List_category"%>
<%@page import="db.entities.List_reg"%>
<%@page import="java.util.List"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="db.factories.DAOFactory"%>
<%@page import="db.exceptions.DAOFactoryException"%>
<%@page import="db.exceptions.DAOException"%>
<%@page import="db.entities.User"%>
<%@page import="db.entities.Product" %>
<%@page import="db.daos.List_regDAO"%>
<%@page import="db.daos.Prod_categoryDAO"%>
<%@page trimDirectiveWhitespaces="true" %>
<%@taglib prefix="my" tagdir="/WEB-INF/tags" %>


<%!
    private UserDAO userDao;
    private Prod_categoryDAO prod_categoryDao;
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
            prod_categoryDao = daoFactory.getDAO(Prod_categoryDAO.class);
        } catch (DAOFactoryException ex) {
            throw new RuntimeException(new ServletException("Impossible to get dao for prod_category", ex));
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
        try {
            productDao = daoFactory.getDAO(ProductDAO.class);
        } catch (DAOFactoryException ex) {
            throw new RuntimeException(new ServletException("Impossible to get the dao for product", ex));
        }
    }

    public void jspDestroy() {
        userDao = null;
        prod_categoryDao = null;
        list_regDao = null;
        list_catDao = null;
        productDao = null;
    }
%>

<%
    if (response.isCommitted()) {
        getServletContext().log("homepage.html is already committed");
    }

    String contextPath = getServletContext().getContextPath();
    if (!contextPath.endsWith("/")) {
        contextPath += "/";
    }

    User user = (User) session.getAttribute("user");

    String currentTab = "mylists";
    if ("sharedlists".equals(request.getParameter("tab")) || "myproducts".equals(request.getParameter("tab"))) {
        currentTab = request.getParameter("tab");
    }
    pageContext.setAttribute("currentTab", currentTab);

    List<List_reg> myLists;
    List<List_reg> sharedLists;
    List<List_category> list_categories;
    List<Product> userProducts;
    List<Prod_category> prod_categories;
    List<List_reg> invites;

    try {
        myLists = userDao.getOwnedLists(user);
        sharedLists = userDao.getSharedLists(user);
        list_categories = list_catDao.getAll();
        userProducts = productDao.filterProducts(null, null, user, false, SortBy.POPULARITY);
        prod_categories = prod_categoryDao.getAll();
        invites = userDao.getInvites(user);
        pageContext.setAttribute("myLists", myLists);
        pageContext.setAttribute("sharedLists", sharedLists);
        pageContext.setAttribute("list_categories", list_categories);
        pageContext.setAttribute("userProducts", userProducts);
        pageContext.setAttribute("prod_categories", prod_categories);
        pageContext.setAttribute("list_catDao", list_catDao);
        pageContext.setAttribute("list_regDao", list_regDao);
        pageContext.setAttribute("contextPath", contextPath);
        pageContext.setAttribute("invites", invites);
    } catch (DAOException ex) {
        System.err.println("Error loading shopping lists (jsp)" + ex);
        if (!response.isCommitted()) {
            response.sendRedirect(contextPath + "error.html?error=");
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Shopping lists manager</title>
        <noscript>
        <META HTTP-EQUIV="Refresh" CONTENT="0;URL=../error.html?error=nojs">
        </noscript>
        <meta name="viewport" content="width=device-width, initial-scale=1" charset="UTF-8">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.7.0/css/all.css" integrity="sha384-lZN37f5QGtY3VHgisS14W3ExzMWZxybE1SJSEsQp9S+oqd12jhcu+A56Ebc1zFSJ" crossorigin="anonymous">

        <!-- Bootstrap core JavaScript ================================================== -->
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"></script>
    </head>
    <body>
        <nav class="navbar navbar-expand-md navbar-dark bg-dark sticky-top shadow">
            <a class="navbar-brand " href="homepage.html">
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
                    <li class="dropdown ml-auto">
                        <form class="form-inline" action="${contextPath}auth" method="POST">
                            <input class="form-control" type="hidden" name="action" value="logout" required/>
                            <button type="submit" class="btn btn-outline-secondary btn-sm">Logout</button>
                        </form>
                    </li>
                </ul>
            </div>
        </nav>
        <main role="main">
            <!-- Main jumbotron for a primary marketing message or call to action -->
            <div class="jumbotron">
                <div class="container-fluid">
                    <h1 class="display-3">Hello, ${user.firstname}!</h1>
                    <p>This is your personal area where you can create and manage shopping lists and even share them with your friends!</p>
                </div>
            </div>
        </main>
        <nav>
            <div class="nav nav-tabs nav-justified shadow-sm" id="nav-tab" role="tablist">
                <my:n>
                    <a class="nav-item nav-link my-auto <c:if test="${currentTab.equals('mylists')}">active</c:if>" id="myLists-tab" data-toggle="tab" href="#nav-myLists" role="tab" onclick="changeTab('mylists')">
                            <h5>My lists</h5>
                        </a>
                        <a class="nav-item nav-link my-auto mx-1 <c:if test="${currentTab.equals('sharedlists')}">active</c:if>" id="sharedLists-tab" data-toggle="tab" href="#nav-sharedLists" role="tab" onclick="changeTab('sharedlists')">
                            <h5>Shared with me</h5>
                        </a>
                        <a class="nav-item nav-link my-auto <c:if test="${currentTab.equals('myproducts')}">active</c:if>" id="sharedLists-tab" data-toggle="tab" href="#nav-myProducts" role="tab" onclick="changeTab('myproducts')">
                            <h5>My products</h5>
                        </a>
                </my:n>
            </div>
        </nav>
        <div class="tab-content" id="nav-tabContent">
            <my:n>
                <div class="tab-pane fade <c:if test="${currentTab.equals('mylists')}">show active</c:if>" id="nav-myLists" role="tabpanel">
                </my:n>
                <div class="row  mx-1">
                    <div class="row ml-auto mr-1 mt-2">
                        <div class="row ml-2 mr-0 my-2">
                            <div class="input-group my-auto">
                                <select class="custom-select" id="ml-search-sort" onchange="showLists()">
                                    <option value="Name" selected>Name</option>
                                    <option value="Completion >">Completion ></option>
                                    <option value="Completion <">Completion <</option>
                                </select>
                            </div>
                        </div>
                        <div class="row mx-2 my-2">
                            <div class="input-group my-auto">
                                <select class="custom-select" id="ml-search-cat" onchange="showLists()">
                                    <option value="-1" selected>All categories</option>
                                    <c:forEach var="cat" items="${list_categories}">
                                        <option value="${cat.id}">${cat.name}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div class="row ml-auto mx-2 my-2">
                            <div class="input-group">                            
                                <input class="form-control" type="search" id="ml-search-name" placeholder="List name" onkeyup="showLists()">
                                <button class="btn btn-outline-success" onclick="showLists()">
                                    <i class="fa fa-search mr-auto" style="font-size:20px;"></i>
                                </button>
                                <button type="button" class="btn btn-primary ml-2 my-auto shadow rounded-circle" href="#createListModal" data-toggle="modal">          
                                    <i class="fa fa-plus mr-auto"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!--Loading my lists-->
                <div class="row justify-content-center mx-auto" id="ml-div">
                </div>
            </div>

            <my:n><div class="tab-pane fade <c:if test="${currentTab.equals('sharedlists')}">show active</c:if>" id="nav-sharedLists" role="tabpanel">
                </my:n>
                <div class="row  mx-1">
                    <div class="row ml-auto mr-1 mt-2">
                        <div class="row ml-2 mr-0 my-2">
                            <div class="input-group my-auto">
                                <select class="custom-select" id="sl-search-sort" onchange="showLists(true)">
                                    <option value="Name" selected>Name</option>
                                    <option value="Completion >">Completion ></option>
                                    <option value="Completion <">Completion <</option>
                                </select>
                            </div>
                        </div>
                        <div class="row mx-2 my-2">
                            <div class="input-group my-auto">
                                <select class="custom-select" id="sl-search-cat" onchange="showLists(true)">
                                    <option value="-1" selected>All categories</option>
                                    <c:forEach var="cat" items="${list_categories}">
                                        <option value="${cat.id}">${cat.name}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div class="row ml-auto mx-2 my-2">
                            <div class="input-group">                            
                                <input class="form-control" type="search" id="sl-search-name" placeholder="List name" onkeyup="showLists(true)">
                                <button class="btn btn-outline-success" onclick="showLists(true)">
                                    <i class="fa fa-search mr-auto" style="font-size:20px;"></i>
                                </button>
                                <button type="button" class="btn btn-primary ml-2 my-auto shadow rounded-circle" href="#importListModal" data-toggle="modal">          
                                    <i class="fa fa-plus mr-auto"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!--Loading shared lists-->
                <div class="row justify-content-center mx-auto" id="sl-div">
                </div>
            </div>

            <my:n><div class="tab-pane fade <c:if test="${currentTab.equals('myproducts')}">show active</c:if>" id="nav-myProducts" role="tabpanel">
                </my:n>
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
                                <input class="form-control" type="search" placeholder="your products..." id="p-search-name" onkeyup="showProducts()">
                                <button class="btn btn-outline-success" onclick="showProducts()">
                                    <i class="fa fa-search mr-auto" style="font-size:20px;"></i>
                                </button>   
                                <button type="button" class="btn btn-primary ml-2 my-auto shadow rounded-circle" href="#createProductModal" data-toggle="modal">          
                                    <i class="fa fa-plus mr-auto"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!--Loading products-->
                <div class="container-fluid" id="p-div">
                </div>
            </div>
        </div>

        <!-- MODALS -->

        <!-- create list -->
        <div class="modal modal-fluid" id="createListModal">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content">
                    <div class="modal-header shadow">
                        <i class="fa fa-cart-plus my-auto mr-auto" style="font-size:30px;"></i>
                        <h5 class="modal-title">Create a list</h5>
                        <button type="button" class="close" data-dismiss="modal">
                            <span>&times;</span>
                        </button>
                    </div>
                    <form id="createListForm" action="${contextPath}restricted/shopping.lists.handler" method="POST" enctype="multipart/form-data">
                        <input type="hidden" name="tab" value="mylists" id="tab-input-0"/>
                        <input type="hidden" name="action" value="create"/>
                        <div class="modal-body mx-3">
                            <div class="md-form mb-3">
                                <i class="fa fa-image prefix grey-text"></i>
                                <label data-error="error" data-success="success">Logo</label>
                                <div class="custom-file">
                                    <input type="file" class="custom-file-input" name="image" accept="image/*">
                                    <label class="custom-file-label">Choose file</label>
                                </div>
                            </div>
                            <div class="md-form mb-3">
                                <i class="fa fa-bookmark prefix grey-text"></i>
                                <label data-error="error" data-success="success" for="productForm">List name</label>
                                <input type="text" class="form-control validate" name="name"/>
                            </div>
                            <div class="md-form mb-3">
                                <i class="fa fa-align-left prefix grey-text"></i>
                                <label data-error="error" data-success="success" for="productForm">Description</label>
                                <textarea class="form-control validate" name="description"></textarea>
                            </div>
                            <div class="input-group">
                                <select name="category" class="form-control">
                                    <c:forEach var="list_cat" items="${list_categories}" varStatus="i">
                                        <option value="${list_cat.id}" <c:if test="${i.index==0}">selected</c:if>>${list_cat.name}</option>
                                    </c:forEach>
                                </select>
                                <div class="input-group-append">
                                    <span class="input-group-text">Category</span>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer form-horizontal">
                            <button type="button" class="btn btn-primary" data-dismiss="modal" onclick="$('#createListForm')[0].submit()">Confirm changes</button> 
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- import list -->
        <div class="modal modal-fluid" id="importListModal">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content">
                    <div class="modal-header shadow">
                        <i class="fa fa-share-alt my-auto mr-auto" style="font-size:30px;"></i>
                        <h5 class="modal-title ml-2">Pending list invites</h5>
                        <button type="button" class="close" data-dismiss="modal">
                            <span>&times;</span>
                        </button>
                    </div>
                    <div class="modal-body" style="height:62vh; overflow-y:scroll; width: 100%">
                        <c:forEach var="invite" items="${invites}">
                            <div class="row px-auto ml-0">
                                <img class="img-thumbnail shadow-sm mr-2 mb-2" style="width: 70px; height: 100%; min-width: 50px; min-height: 100%" alt="Responsive image" src="../images/shopping_lists/${invite.id}">
                                <p class="mr-2 my-auto">
                                    ${invite.name}
                                </p>
                                <p class="mr-2 ml-auto my-auto" style="color: grey">
                                    ${invite.owner.firstname}&nbsp;${invite.owner.lastname}
                                </p>
                                <div class="row ml-auto mx-2 my-2">
                                    <div class="input-group my-auto">
                                        <form id="invites-form-${invite.id}" class="form-inline" action="${contextPath}restricted/shareShoppingList.handler" method="POST">
                                            <input id="invites-action-${invite.id}" type="hidden" name="action">
                                            <input type="hidden" name="list_id" value="${invite.id}">
                                            <button type="submit" class="btn btn-success my-auto mx-2 ml-auto shadow-sm rounded" onclick="acceptInvite(${invite.id})">
                                                <i class="fas fa-check" style="font-size:25px"></i>
                                            </button>
                                            <button class="btn btn-danger my-auto mx-2 shadow-sm rounded" onclick="declineInvite(${invite.id})">
                                                <i class="fas fa-times" style="font-size:25px"></i>
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                            <hr>
                        </c:forEach>
                    </div>
                </div>
            </div>
        </div>

        <!-- create product -->
        <div class="modal modal-fluid" id="createProductModal">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content">
                    <div class="modal-header shadow">
                        <i class="fa fa-cart-plus my-auto mr-auto" style="font-size:30px;"></i>
                        <h5 class="modal-title">Create a product</h5>
                        <button type="button" class="close" data-dismiss="modal">
                            <span>&times;</span>
                        </button>
                    </div>
                    <form id="createProductForm" action="${contextPath}restricted/product.handler" method="POST" enctype="multipart/form-data">
                        <input type="hidden" name="tab" value="myproducts" id="tab-input-1"/>
                        <input type="hidden" name="action" value="create"/>
                        <div class="modal-body mx-3">
                            <div class="md-form mb-3">
                                <i class="fa fa-image prefix grey-text"></i>
                                <label data-error="error" data-success="success">Logo</label>
                                <div class="custom-file">
                                    <input type="file" class="custom-file-input" name="image" accept="image/*">
                                    <label class="custom-file-label">Choose file</label>
                                </div>
                            </div>
                            <div class="md-form mb-3">
                                <i class="fa fa-bookmark prefix grey-text"></i>
                                <label data-error="error" data-success="success" for="productForm">Product name</label>
                                <input type="text" class="form-control validate" name="name"/>
                            </div>
                            <div class="md-form mb-3">
                                <i class="fa fa-align-left prefix grey-text"></i>
                                <label data-error="error" data-success="success" for="productForm">Description</label>
                                <textarea class="form-control validate" name="description"></textarea>
                            </div>
                            <div class="input-group">
                                <select class="form-control" name="category">
                                    <c:forEach var="prod_cat" items="${prod_categories}" varStatus="i">
                                        <option value="${prod_cat.id}" <c:if test="${i.index==0}">selected</c:if>>${prod_cat.name}</option>
                                    </c:forEach>
                                </select>
                                <div class="input-group-append">
                                    <span class="input-group-text">Category</span>
                                </div>
                            </div>
                        </div>
                    </form>
                    <div class="modal-footer form-horizontal">
                        <button type="button" class="btn btn-primary" data-dismiss="modal" onclick="$('#createProductForm')[0].submit()">Create</button> 
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </div>
        </div>

        <!--Edit product modal-->
        <div class="modal modal-fluid" id="editProductModal">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content">
                    <div class="modal-header shadow">
                        <i class="fa fa-cart-plus my-auto mr-auto" style="font-size:30px;"></i>
                        <h5 class="modal-title">Edit product</h5>
                        <button type="button" class="close" data-dismiss="modal">
                            <span>&times;</span>
                        </button>
                    </div>
                    <div class="modal-body mx-3">
                        <form id="editProductForm" action="${contextPath}restricted/product.handler" method="POST" enctype="multipart/form-data">
                            <input type="hidden" name="tab" value="myproducts" id="tab-input-2"/>
                            <input type="hidden" name="action" value="edit"/>
                            <input type="hidden" name="prodID" value="" id="editProductForm-prodID"/>
                            <div class="md-form mb-3">
                                <i class="fa fa-image prefix grey-text"></i>
                                <label data-error="error" data-success="success">Logo</label>
                                <div class="custom-file">
                                    <input type="file" class="custom-file-input" name="image" accept="image/*">
                                    <label class="custom-file-label">Choose file</label>
                                </div>
                            </div>
                            <div class="md-form mb-3">
                                <i class="fa fa-bookmark prefix grey-text"></i>
                                <label data-error="error" data-success="success" for="productForm">Product name</label>
                                <input type="text" class="form-control validate" name="name" id="editProductForm-name"/>
                            </div>
                            <div class="md-form mb-3">
                                <i class="fa fa-align-left prefix grey-text"></i>
                                <label data-error="error" data-success="success" for="productForm">Description</label>
                                <textarea class="form-control validate" name="description" id="editProductForm-description"></textarea>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer form-horizontal">
                        <button type="button" class="btn btn-primary" data-dismiss="modal" onclick="$('#editProductForm')[0].submit()">Confirm</button> 
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </div>
        </div>

        <!--Delete product modal-->
        <div class="modal modal-centered" id="deleteProductModal" data-backdrop="static" data-keyboard="false">
            <div class="modal-dialog modal-dialog-centered modal-sm">
                <div class="modal-content">
                    <div class="modal-header shadow">
                        <i class="fa fa-exclamation-triangle my-auto mr-auto" style="font-size:25px; color: crimson"></i>
                        <h5 class="modal-title">Delete product?</h5>
                        <button type="button" class="close" data-dismiss="modal">
                            <span>&times;</span>
                        </button>
                    </div>
                    <form id="deleteProductForm" action="${contextPath}restricted/product.handler" method="POST">
                        <input type="hidden" name="tab" value="myproducts" id="tab-input-2"/>
                        <input type="hidden" name="action" value="delete"/>
                        <input type="hidden" name="prodID" value="" id="deleteProductForm-prodID"/>
                    </form>
                    <div class="modal-footer form-horizontal">
                        <button type="button" class="btn btn-danger" data-dismiss="modal" onclick="$('#deleteProductForm')[0].submit()">Confirm</button> 
                        <button type="button" class="btn btn-success" data-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </div>
        </div>

        <footer class="footer font-small blue pt-3">
            <div class="p-3 mb-2 bg-dark text-white">
                Follow us on Github: <a href="https://github.com/AndreiDiaconu97/Shopping_Lists"> Shopping_Lists</a>
            </div>
        </footer>


        <script>
            var user_products = ${Product.toJSON(userProducts)};
            var prod_categories = ${Prod_category.toJSON(prod_categories)};
            var user_lists = ${List_reg.toJSON(myLists)};
            var shared_lists = ${List_reg.toJSON(sharedLists)};

            function showLists(shared) {
                let id = shared === true ? 'sl' : 'ml';
                let sortby = $('#' + id + '-search-sort')[0].value;
                let lcatID = $('#' + id + '-search-cat')[0].value;
                let name = $('#' + id + '-search-name')[0].value;
                let lists = shared === true ? shared_lists : user_lists;
                if (lcatID !== "-1") {
                    lists = lists.filter(l => l.category.id.toString() === lcatID);
                }
                lists = lists.filter(l => l.name.toUpperCase().includes(name.toUpperCase()));
                switch (sortby) {
                    case "Completion >":
                        lists.sort((l, r) => {
                            let p_l = l.purchased;
                            let t_l = l.total;
                            let p_r = r.purchased;
                            let t_r = r.total;
                            return (100 * ++p_r / ++t_r) - (100 * ++p_l / ++t_l);
                        });
                        break;
                    case "Completion <":
                        lists.sort((l, r) => {
                            let p_l = l.purchased;
                            let t_l = l.total;
                            let p_r = r.purchased;
                            let t_r = r.total;
                            return (100 * ++p_l / ++t_l) - (100 * ++p_r / ++t_r);
                        });
                        break;
                    default:// name or nothing
                        lists.sort((l, r) => l.name > r.name ? 1 : -1);
                        break;
                }

                let innerhtml = "";
                for (l of lists) {
                    let lhtml = '<a href="shopping.list.html?listID=' + l.id + '" class="my-3 mx-4">'
                            + '<div class="card text-dark" style="width: 16rem; display: inline-block">'
                            + '<div class="card-header" style="font-weight: bold; background-color: ' + getRGB(l.purchased, l.total) + '">'
                            + l.name
                            + '</div>'
                            + '<img class="card-img-top" src="../images/shopping_lists/' + l.id + '" alt="Card image cap">';
                    if (shared) {
                        lhtml += '<div class="card-body" style="font-size: 15px; text-align: right">'
                                + l.owner.firstname + ' ' + l.owner.lastname
                                + '<i class="fa fa-user" style="font-size:20px;"></i>'
                                + '</div>';
                    }
                    lhtml += '<div class="card-footer text-muted" style="background-color: ' + getRGB(l.purchased, l.total) + '">'
                            + l.category.name
                            + '<span class="badge badge-pill badge-secondary float-right">' + l.purchased + '/' + l.total + '</span>'
                            + '</div>'
                            + '</div>'
                            + '</a>';
                    innerhtml += lhtml;
                }
                $('#' + id + '-div')[0].innerHTML = innerhtml;
            }

            function showProducts() {
                let sortby = $('#p-search-sort')[0].value;
                let pcatID = $('#p-search-cat')[0].value;
                let name = $('#p-search-name')[0].value;
                let products = user_products.slice();
                if (pcatID !== "-1") {
                    products = products.filter(p => p.category.id.toString() === pcatID);
                }
                products = products.filter(p => p.name.toUpperCase().includes(name.toUpperCase()));
                switch (sortby) {
                    case "Rating":
                        products.sort((l, r) => l.rating > r.rating ? 1 : -1);
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
                            + '<div class="card shadow-sm mb-2">'
                            + '<div class="card-body">'
                            + '<div class="row">'
                            + '<img class="img-fluid img-thumbnail rounded mx-2" style="min-width: 50px; min-height: 100%; max-width: 100%; max-height: 60px"  alt="Responsive image" src="../images/products/' + p.id + '">'
                            + '<div class="text-left my-auto">'
                            + p.name
                            + '</div>'
                            + '<div class="row ml-auto my-auto mr-1 pt-2">'
                            + '<div class="input-group">'
                            + '<button type="button" id="modifyProdBtn' + p.id + '" class="btn btn-info btn-sm shadow-sm mr-2" data-toggle="modal" data-target="#editProductModal" onclick="fillEditProductForm(' + p.id + ')">'
                            + '<i class="fa fa-edit mr-auto" style="font-size: 28px"></i>'
                            + '</button>'
                            + '<button type="button" id="deleteProdBtn' + p.id + '" class="btn btn-info btn-sm shadow-sm mr-2" style="background-color: crimson" data-toggle="modal" data-target="#deleteProductModal" onclick="fillDeleteProductForm(' + p.id + ')">'
                            + '<i class="fa fa-trash mr-auto" style="font-size: 28px"></i>'
                            + '</button>'
                            + '</div>'
                            + '</div>'
                            + '</div>'
                            + '</div>'
                            + '</div>';
                }
                $('#p-div')[0].innerHTML = innerhtml;
            }

            function fillEditProductForm(id) {
                let prod = user_products.filter(p => p.id === id)[0];
                $('#editProductForm-prodID')[0].value = prod.id;
                $('#editProductForm-name')[0].value = prod.name;
                $('#editProductForm-description')[0].innerHTML = prod.description;
                $('#editProductForm-category')[0].selectedIndex = prod_categories.findIndex(c => c.id === prod.category.id);
            }

            function fillDeleteProductForm(id) {
                $('#deleteProductForm-prodID')[0].value = id;
            }

            function getRGB(purchased, total) {
                purchased++;
                total++;
                return "rgb(" + 500 * (total - purchased) / total + "," + 500 * purchased / total + ",0)";
            }

            function changeTab(tab) {
                window.history.pushState(null, null, '${contextPath}restricted/homepage.html?tab=' + tab);
            }

            showLists();
            showLists(true);
            showProducts();
            changeTab('${currentTab}');
            
            function acceptInvite(id){
                $('#invites-action-' + id)[0].value = 'accept';
                $('#invites-form-' + id)[0].submit();
            }
            
            function declineInvite(id){
                $('#invites-action-' + id)[0].value = 'decline';
                $('#invites-form-' + id)[0].submit();
            }
        </script>
    </body>
</html>

