<%@page import="java.util.ArrayList"%>
<%@page import="db.daos.jdbc.JDBC_utility.SortBy"%>
<%@page import="db.entities.Product"%>
<%@page import="java.util.List"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="db.factories.DAOFactory"%>
<%@page import="db.exceptions.DAOFactoryException"%>
<%@page import="db.daos.List_categoryDAO"%>
<%@page import="db.daos.Prod_categoryDAO"%>
<%@page import="db.daos.List_regDAO"%>
<%@page import="db.daos.ProductDAO"%>
<%@page import="db.daos.UserDAO"%>
<%@page import="db.entities.User"%>
<%@page import="db.entities.List_category"%>
<%@page import="db.entities.Prod_category"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    private UserDAO userDao;
    private List_regDAO list_regDao;
    private List_categoryDAO list_catDao;
    private Prod_categoryDAO prod_catDao;
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
            throw new RuntimeException(new ServletException("Impossible to get the dao for shop_list", ex));
        }
        try {
            list_catDao = daoFactory.getDAO(List_categoryDAO.class);
        } catch (DAOFactoryException ex) {
            throw new RuntimeException(new ServletException("Impossible to get the dao for list_cat", ex));
        }
        try {
            prod_catDao = daoFactory.getDAO(Prod_categoryDAO.class);
        } catch (DAOFactoryException ex) {
            throw new RuntimeException(new ServletException("Impossible to get the dao for prod_cat", ex));
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
        if (prod_catDao != null) {
            prod_catDao = null;
        }
        if (productDao != null) {
            productDao = null;
        }
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

    String currentTab = "listCats";
    if ("prodCats".equals(request.getParameter("tab")) || ("publicProds".equals(request.getParameter("tab")))) {
        currentTab = request.getParameter("tab");
    }
    pageContext.setAttribute("currentTab", currentTab);

    List<List_category> list_categories;
    List<Prod_category> prod_categories;
    List<Product> publicProducts;
    List<List<Prod_category>> own_prod_categoriesOflist_cat = new ArrayList<>();
    try {
        list_categories = list_catDao.getAll();
        prod_categories = prod_catDao.getAll();
        publicProducts = productDao.filterProducts(null, null, null, true, SortBy.POPULARITY);

        List<Prod_category> own_prod_categories;
        for (List_category list_cat : list_categories) {
            own_prod_categories = list_catDao.getProd_categories(list_cat, true);
            own_prod_categoriesOflist_cat.add(own_prod_categories);
        }

        pageContext.setAttribute("list_categories", list_categories);
        pageContext.setAttribute("prod_categories", prod_categories);
        pageContext.setAttribute("publicProducts", publicProducts);
        pageContext.setAttribute("own_prod_categoriesOflist_cat", own_prod_categoriesOflist_cat);
    } catch (Exception ex) {
        System.err.println("Error loading admin (jsp)" + ex);
        if (!response.isCommitted()) {
            response.sendRedirect(contextPath + "error.html?error=");
        }
    }

%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Shopping lists manager - admin area</title>
        <noscript>
        <META HTTP-EQUIV="Refresh" CONTENT="0;URL=../error.html?error=nojs">
        </noscript>
        <meta name="viewport" content="width=device-width, initial-scale=1" charset="UTF-8">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"></script>
    </head>
    <body>
        <nav class="navbar navbar-expand-md navbar-dark bg-dark sticky-top shadow">
            <a class="navbar-brand " href="admin.html">
                <i class="fa fa-shopping-cart" style="font-size:30px"></i>
                Shopping lists - admin area
            </a>
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarSupportedContent">
                <ul class="nav navbar-nav ml-auto">
                    <li class="dropdown ml-auto">
                        <div class="text-white mx-2">logged in as <b>${user.email}</b></div>
                    </li>                    
                    <li class="dropdown ml-auto">
                        <form class="form-inline" action="<%=contextPath%>auth" method="POST" method="POST">
                            <input class="form-control" type="hidden" name="action" value="logout" required>
                            <button type="submit" class="btn btn-outline-secondary btn-sm">Logout</button>
                        </form>
                    </li>
                </ul>
            </div>
        </nav>
        <main role="main">
            <div class="jumbotron">
                <div class="container-fluid">
                    <h1 class="display-3">Welcome, ${user.firstname}</h1>
                    <p>You are logged as admin, in this area you can manage the shopping list categories, the product categories and the public products.</p>
                </div>
            </div>
        </main>
        <nav>
            <div class="nav nav-tabs nav-justified shadow-sm" id="myTab" role="tablist">
                <a class="nav-item nav-link my-auto <c:if test="${currentTab.equals('listCats')}">active</c:if>" id="listCategories-tab" data-toggle="tab" href="#nav-listCategories" role="tab" onclick="changeTab('listCats')">
                        <h5>List categories</h5>
                    </a>
                    <a class="nav-item nav-link my-auto mx-1 <c:if test="${currentTab.equals('prodCats')}">active</c:if>" id="prodCategories-tab" data-toggle="tab" href="#nav-prodCategories" role="tab" onclick="changeTab('prodCats')">
                        <h5>Product categories</h5>
                    </a>
                    <a class="nav-item nav-link my-auto <c:if test="${currentTab.equals('publicProds')}">active</c:if>" id="prodCategories-tab" data-toggle="tab" href="#nav-publicProducts" role="tab" onclick="changeTab('publicProds')">
                        <h5>Public products</h5>
                    </a>
                </div>
            </nav>
            <div class="tab-content" id="nav-tabContent">
                <!-- List categories search bar -->
                <div class="tab-pane fade <c:if test="${currentTab.equals('listCats')}">show active</c:if>" id="nav-listCategories" role="tabpanel" aria-labelledby="nav-listCategories">
                    <div class="row mx-1">
                        <div class="row ml-auto mr-1 mt-2">
                            <div class="row ml-auto mx-2 my-2">
                                <div class="input-group">                            
                                    <input class="form-control" type="search" placeholder="list categories..." aria-label="Search" id="listCat-search-name" onkeyup="showListCategories()">
                                    <div class="input-group-append">
                                        <label class="input-group-text rounded" for="inputGroupSelect02">
                                            <i class="fa fa-search"></i>
                                        </label>
                                    </div>    
                                    <button type="button" class="btn btn-primary ml-2 my-auto shadow rounded-circle" href="#createListCategoryModal" data-toggle="modal">          
                                        <i class="fa fa-plus mr-auto"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- load list categories -->
                    <div class="container-fluid" id="listCat-div">
                    </div>
                </div>
                <!-- Product categories search bar -->
                <div class="tab-pane fade <c:if test="${currentTab.equals('prodCats')}">show active</c:if>" id="nav-prodCategories" role="tabpanel" aria-labelledby="nav-prodCategories">
                    <div class="row mx-1">
                        <div class="row ml-auto mr-1 mt-2">
                            <div class="row ml-2 mr-0 my-2">
                                <div class="input-group my-auto">
                                    <select class="custom-select" id="prodCat-search-sort" onchange="showProductCategories()">
                                        <option value="Name">Name</option>
                                        <option value="Renew time >">Renew time ></option>
                                        <option value="Renew time <">Renew time <</option>
                                    </select>
                                </div>
                            </div>
                            <div class="row mx-2 my-2">
                                <div class="input-group my-auto">
                                    <select class="custom-select" id="prodCat-search-cat" onchange="showProductCategories()">
                                        <option value="-1" selected>All categories</option>
                                    <c:forEach var="listCat" varStatus="i" items="${list_categories}">
                                        <option value="${i.index}">${listCat.name}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        <div class="row ml-auto mx-2 my-2">
                            <div class="input-group">                            
                                <input class="form-control" type="search" placeholder="product categories..." aria-label="Search" id="prodCat-search-name"  onkeyup="showProductCategories()">
                                <div class="input-group-append">
                                    <label class="input-group-text rounded" for="inputGroupSelect02">
                                        <i class="fa fa-search"></i>
                                    </label>
                                </div>  
                                <button type="button" class="btn btn-primary ml-2 my-auto shadow rounded-circle" href="#createProductCatModal" data-toggle="modal">          
                                    <i class="fa fa-plus mr-auto"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- load product categories -->
                <div class="container-fluid" id="prodCat-div">
                </div>
            </div>
            <!-- Public products search bar -->
            <div class="tab-pane fade <c:if test="${currentTab.equals('publicProds')}">show active</c:if>" id="nav-publicProducts" role="tabpanel" aria-labelledby="nav-publicProducts">
                    <div class="row mx-1">
                        <div class="row ml-auto mr-1 mt-2">
                            <div class="row ml-2 mr-0 my-2">
                                <div class="input-group my-auto">
                                    <select class="custom-select" id="p-search-sort" onchange="showProducts()">
                                        <option value="Name">Name</option>
                                        <option value="Rating">Rating</option>
                                        <option value="Popularity" selected="">Popularity</option>
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
                                <input class="form-control" type="search" placeholder="public products..." id="p-search-name" onkeyup="showProducts()" aria-label="Search">
                                <div class="input-group-append">
                                    <label class="input-group-text rounded" for="inputGroupSelect02">
                                        <i class="fa fa-search"></i>
                                    </label>
                                </div>  
                                <button type="button" class="btn btn-primary ml-2 my-auto shadow rounded-circle" href="#createProduct-modal" data-toggle="modal">          
                                    <i class="fa fa-plus mr-auto"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- load public products -->
                <div class="container-fluid" id="publicProd-div">
                </div>
            </div>
        </div>    

        <!-- MODALS -->

        <!-- create list category -->
        <div class="modal modal-fluid" id="createListCategoryModal" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header shadow">
                        <i class="fa fa-list-alt my-auto mr-auto" style="font-size:30px;"></i>
                        <h5 class="modal-title">Create a list category</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body mx-3">
                        <form id="createListCat-form" action="${contextPath}admin.handler" method="POST" enctype="multipart/form-data">
                            <input type="hidden" name="action" value="listcat"/>
                            <input type="hidden" name="tab" value="listCats"/>
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
                                <label data-error="error" data-success="success">List category name</label>
                                <input type="text" class="form-control validate" name="name"/>
                            </div>
                            <div class="md-form mb-3">
                                <i class="fa fa-align-left prefix grey-text"></i>
                                <label data-error="error" data-success="success">Description</label>
                                <textarea class="form-control validate" name="description"></textarea>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer form-horizontal">
                        <button type="button" class="btn btn-primary" data-dismiss="modal" onclick="$('#createListCat-form').submit()">Confirm changes</button> 
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- create product category -->
        <div class="modal modal-fluid" id="createProductCatModal" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header shadow">
                        <i class="fa fa-cog my-auto mr-auto" style="font-size:30px;"></i>
                        <h5 class="modal-title">Create product category</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body mx-3">
                        <form id="createProdCat-form" action="${contextPath}admin.handler" method="POST" enctype="multipart/form-data">
                            <input type="hidden" name="action" value="productcat"/>
                            <input type="hidden" name="tab" value="prodCats"/>
                            <div class="md-form mb-3">
                                <i class="fa fa-image prefix grey-text"></i>
                                <label data-error="error" data-success="success" for="editListCat-form">Logo</label>
                                <div class="custom-file">
                                    <input type="file" class="custom-file-input" name="image" accept="image/*">
                                    <label class="custom-file-label" for="editListCat-form">Choose file</label>
                                </div>
                            </div>
                            <div class="md-form mb-3">
                                <i class="fa fa-bookmark prefix grey-text"></i>
                                <label data-error="error" data-success="success">List category name</label>
                                <input type="text" class="form-control validate" name="name"/>
                            </div>
                            <div class="md-form mb-3">
                                <i class="fa fa-align-left prefix grey-text"></i>
                                <label data-error="error" data-success="success">Description</label>
                                <textarea class="form-control validate" name="description"></textarea>
                            </div>
                            <div class="md-form mb-3">
                                <i class="fa fa-repeat prefix grey-text"></i>
                                <label data-error="error" data-success="success">Renew time</label>
                                <input type="number" class="form-control validate" name="renew_time"></input>
                            </div>
                            <div class="input-group">
                                <select name="list_category" class="form-control">
                                    <c:forEach var="list_cat" items="${list_categories}" varStatus="i">
                                        <option value="${list_cat.id}" <c:if test="${i.index==0}">selected</c:if>>${list_cat.name}</option>
                                    </c:forEach>
                                </select>
                                <div class="input-group-append">
                                    <span class="input-group-text">List category</span>
                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer form-horizontal">
                        <button type="button" class="btn btn-primary" data-dismiss="modal" onclick="$('#createProdCat-form').submit()">Confirm changes</button> 
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- create public products -->
        <div class="modal modal-fluid" id="createProduct-modal" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header shadow">
                        <i class="fa fa-cog my-auto mr-auto" style="font-size:30px;"></i>
                        <h5 class="modal-title">Edit product</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body mx-3">
                        <form id="createProduct-form" action="${contextPath}admin.handler" method="POST" enctype="multipart/form-data">
                            <input type="hidden" name="action" value="product"/>
                            <input type="hidden" name="tab" value="publicProds"/>
                            <div class="md-form mb-3">
                                <i class="fa fa-image prefix grey-text"></i>
                                <label data-error="error" data-success="success" for="editListCat-form">Logo</label>
                                <div class="custom-file">
                                    <input type="file" class="custom-file-input" name="image" accept="image/*">
                                    <label class="custom-file-label" for="editListCat-form">Choose file</label>
                                </div>
                            </div>
                            <div class="md-form mb-3">
                                <i class="fa fa-bookmark prefix grey-text"></i>
                                <label data-error="error" data-success="success">Product name</label>
                                <input type="text" class="form-control validate" name="name"/>
                            </div>
                            <div class="md-form mb-3">
                                <i class="fa fa-align-left prefix grey-text"></i>
                                <label data-error="error" data-success="success">Description</label>
                                <textarea class="form-control validate" name="description"></textarea>
                            </div>
                            <div class="input-group">
                                <select name="category" class="form-control">
                                    <c:forEach var="prod_cat" items="${prod_categories}" varStatus="i">
                                        <option value="${prod_cat.id}" <c:if test="${i.index==0}">selected</c:if>>${prod_cat.name}</option>
                                    </c:forEach>
                                </select>
                                <div class="input-group-append">
                                    <span class="input-group-text">List category</span>
                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer form-horizontal">
                        <button type="button" class="btn btn-primary" data-dismiss="modal" onclick="$('#createProduct-form').submit()">Confirm changes</button> 
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- edit list category -->
        <div class="modal modal-fluid" id="editListCat-modal" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header shadow">
                        <i class="fa fa-cog my-auto mr-auto" style="font-size:30px;"></i>
                        <h5 class="modal-title">Edit list category</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body mx-3">
                        <form id="editListCat-form" action="${contextPath}admin.handler" method="POST" enctype="multipart/form-data">
                            <input type="hidden" name="action" value="listcat"/>
                            <input type="hidden" name="id" id="editListCat-id"/>
                            <input type="hidden" name="tab" value="listCats"/>
                            <div class="md-form mb-3">
                                <i class="fa fa-image prefix grey-text"></i>
                                <label data-error="error" data-success="success" for="editListCat-form">Logo</label>
                                <div class="custom-file">
                                    <input type="file" class="custom-file-input" name="image" accept="image/*">
                                    <label class="custom-file-label" for="editListCat-form">Choose file</label>
                                </div>
                            </div>
                            <div class="md-form mb-3">
                                <i class="fa fa-bookmark prefix grey-text"></i>
                                <label data-error="error" data-success="success" for="editListCat-form">List category name</label>
                                <input type="text" class="form-control validate" name="name" id="editListCat-name"/>
                            </div>
                            <div class="md-form mb-3">
                                <i class="fa fa-align-left prefix grey-text"></i>
                                <label data-error="error" data-success="success" for="editListCat-form">Description</label>
                                <textarea class="form-control validate" name="description"  id="editListCat-desc"></textarea>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer form-horizontal">
                        <button type="button" class="btn btn-primary" data-dismiss="modal" onclick="$('#editListCat-form').submit()">Confirm changes</button> 
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- edit product category -->
        <div class="modal modal-fluid" id="editProdCat-modal" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header shadow">
                        <i class="fa fa-cog my-auto mr-auto" style="font-size:30px;"></i>
                        <h5 class="modal-title">Edit product category</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body mx-3">
                        <form id="editProdCat-form" action="${contextPath}admin.handler" method="POST" enctype="multipart/form-data">
                            <input type="hidden" name="action" value="productcat"/>
                            <input type="hidden" name="id" id="editProdCat-id"/>
                            <input type="hidden" name="tab" value="prodCats"/>
                            <div class="md-form mb-3">
                                <i class="fa fa-image prefix grey-text"></i>
                                <label data-error="error" data-success="success" for="editListCat-form">Logo</label>
                                <div class="custom-file">
                                    <input type="file" class="custom-file-input" name="image" accept="image/*">
                                    <label class="custom-file-label" for="editListCat-form">Choose file</label>
                                </div>
                            </div>
                            <div class="md-form mb-3">
                                <i class="fa fa-bookmark prefix grey-text"></i>
                                <label data-error="error" data-success="success" for="editListCat-form">List category name</label>
                                <input type="text" class="form-control validate" name="name" id="editProdCat-name"/>
                            </div>
                            <div class="md-form mb-3">
                                <i class="fa fa-align-left prefix grey-text"></i>
                                <label data-error="error" data-success="success" for="editListCat-form">Description</label>
                                <textarea class="form-control validate" name="description"  id="editProdCat-desc"></textarea>
                            </div>
                            <div class="md-form mb-3">
                                <i class="fa fa-repeat prefix grey-text"></i>
                                <label data-error="error" data-success="success" for="editListCat-form">Renew time</label>
                                <input type="number" class="form-control validate" name="renew_time"  id="editProdCat-renew"></input>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer form-horizontal">
                        <button type="button" class="btn btn-primary" data-dismiss="modal" onclick="$('#editProdCat-form').submit()">Confirm changes</button> 
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- edit public products -->
        <div class="modal modal-fluid" id="editProduct-modal" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header shadow">
                        <i class="fa fa-cog my-auto mr-auto" style="font-size:30px;"></i>
                        <h5 class="modal-title">Edit product</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body mx-3">
                        <form id="editProduct-form" action="${contextPath}admin.handler" method="POST" enctype="multipart/form-data">
                            <input type="hidden" name="action" value="product"/>
                            <input type="hidden" name="id" id="editProduct-id"/>
                            <input type="hidden" name="tab" value="publicProds"/>
                            <div class="md-form mb-3">
                                <i class="fa fa-image prefix grey-text"></i>
                                <label data-error="error" data-success="success" for="editProduct-form">Logo</label>
                                <div class="custom-file">
                                    <input type="file" class="custom-file-input" name="image" accept="image/*">
                                    <label class="custom-file-label" for="editProduct-form">Choose file</label>
                                </div>
                            </div>
                            <div class="md-form mb-3">
                                <i class="fa fa-bookmark prefix grey-text"></i>
                                <label data-error="error" data-success="success" for="editProduct-form">Product name</label>
                                <input type="text" class="form-control validate" name="name" id="editProduct-name"/>
                            </div>
                            <div class="md-form mb-3">
                                <i class="fa fa-align-left prefix grey-text"></i>
                                <label data-error="error" data-success="success" for="editProduct-form">Description</label>
                                <textarea class="form-control validate" name="description"  id="editProduct-desc"></textarea>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer form-horizontal">
                        <button type="button" class="btn btn-primary" data-dismiss="modal" onclick="$('#editProduct-form').submit()">Confirm changes</button> 
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </div>
        </div>

        <script>
            var list_categories = ${List_category.toJSON(list_categories)};
            var prod_categories = ${Prod_category.toJSON(prod_categories)};
            var publicProducts = ${Product.toJSON(publicProducts)};
            var own_prod_categoriesOflist_cat = [];
            <c:forEach var="own_prod_categories" items="${own_prod_categoriesOflist_cat}">
            own_prod_categoriesOflist_cat.push(${Prod_category.toJSON(own_prod_categories)});
            </c:forEach>

            function editListCatModal(listCatID) {
                list_cat = list_categories.filter(item => {
                    return item.id === listCatID;
                })[0];
                $("#editListCat-id")[0].value = listCatID;
                $("#editListCat-name")[0].value = list_cat.name;
                $("#editListCat-desc")[0].value = list_cat.description;
            }

            function editProdCatModal(prodCatID) {
                prod_cat = prod_categories.filter(item => {
                    return item.id === prodCatID;
                })[0];
                $("#editProdCat-id")[0].value = prodCatID;
                $("#editProdCat-name")[0].value = prod_cat.name;
                $("#editProdCat-desc")[0].value = prod_cat.description;
                $("#editProdCat-renew")[0].value = prod_cat.renewtime;
            }

            function editProductModal(productID) {
                product = publicProducts.filter(item => item.id === productID)[0];
                $("#editProduct-id")[0].value = productID;
                $("#editProduct-name")[0].value = product.name;
                $("#editProduct-desc")[0].value = product.description;
                $("#editProduct-category")[0].value = product.category.id;
            }

            function showListCategories() {
                let name = $('#listCat-search-name')[0].value;
                let listCats = list_categories.slice();

                listCats = listCats.filter(p => p.name.toUpperCase().includes(name.toUpperCase()));

                let innerhtml = "";
                for (listCategory of listCats) {
                    innerhtml = innerhtml
                            + '<div class="card shadow-sm mb-2">'
                            + '<div class="card-body">'
                            + '<div class="row">'
                            + '<div class="row ml-2 mr-0 my-auto">'
                            + '<img class="img-fluid rounded mr-2" style="min-width: 50px; min-height: 100%; max-width: 100%; max-height: 60px"  alt="Responsive image" src="../images/list_categories/' + listCategory.id + '">'
                            + '<div class="text-left my-auto">' + listCategory.name + '</div>'
                            + '</div>'
                            + '<div class="row ml-auto my-auto mr-1 pt-2">'
                            + '<div class="input-group">'
                            + '<a type="button" class="btn btn-primary btn-sm shadow-sm mr-2" href="list.cat.html?list_catID=' + listCategory.id + '">'
                            + '<i class="fa fa-list-alt" style="font-size: 25px"></i>'
                            + '</a>'
                            + '<button type="button" class="btn btn-info btn-sm shadow-sm mr-2" href="#editListCat-modal" data-toggle="modal" onclick="editListCatModal(' + listCategory.id + ')">'
                            + '<i class="fa fa-edit" style="font-size: 25px"></i>'
                            + '</button>'
                            + '</div>'
                            + '</div>'
                            + '</div>'
                            + '</div>'
                            + '</div>';
                }
                $('#listCat-div')[0].innerHTML = innerhtml;
            }

            function showProductCategories() {
                let sortby = $('#prodCat-search-sort')[0].value;
                let lcatID = $('#prodCat-search-cat')[0].value;
                let name = $('#prodCat-search-name')[0].value;
                let prodCategories;
                if (lcatID !== "-1") {
                    prodCategories = own_prod_categoriesOflist_cat[lcatID];
                } else {
                    prodCategories = prod_categories.slice();
                }
                prodCategories = prodCategories.filter(p => p.name.toUpperCase().includes(name.toUpperCase()));
                switch (sortby) {
                    case "Renew time >":
                        prodCategories.sort((l, r) => l.renewtime > r.renewtime ? 1 : -1);
                        break;
                    case "Renew time <":
                        prodCategories.sort((l, r) => l.renewtime < r.renewtime ? 1 : -1);
                        break;
                    default:
                        // Name
                        prodCategories.sort((l, r) => l.name > r.name ? 1 : -1);
                        break;
                }
                let innerhtml = "";
                for (prodCat of prodCategories) {
                    innerhtml = innerhtml
                            + '<div class = "card shadow-sm mb-2">'
                            + '<div class="card-body">'
                            + '<div class="row">'
                            + '<img class="img-fluid rounded mx-2" style="min-width: 50px; min-height: 100%; max-width: 100%; max-height: 60px"  alt="Responsive image" src="../images/product_categories/' + prodCat.id + '">'
                            + '<div class="text-left my-auto">' + prodCat.name + '</div>'
                            + '<div class="row ml-auto my-auto mr-1 pt-2">'
                            + '<div class="input-group">'
                            + '<button type="button" class="btn btn-info btn-sm shadow-sm mr-2" href="#editProdCat-modal" data-toggle="modal" onclick="editProdCatModal(' + prodCat.id + ')">'
                            + '<i class="fa fa-edit mr-auto" style="font-size: 28px"></i>'
                            + '</button>'
                            + '</div>'
                            + '</div>'
                            + '</div>'
                            + '</div>'
                            + '</div>';
                }
                $('#prodCat-div')[0].innerHTML = innerhtml;
            }

            function showProducts() {
                let sortby = $('#p-search-sort')[0].value;
                let pcatID = $('#p-search-cat')[0].value;
                let name = $('#p-search-name')[0].value;
                let products = publicProducts.slice();
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
                products = products.slice(0,29);
                let innerhtml = "";
                for (p of products) {
                    innerhtml = innerhtml
                            + '<div class="card shadow-sm mb-2">'
                            + '<div class="card-body">'
                            + '<div class="row">'
                            + '<img class="img-fluid rounded mx-2" style="min-width: 50px; min-height: 100%; max-width: 100%; max-height: 60px"  alt="Responsive image" src="../images/products/' + p.id + '">'
                            + '<div class="text-left my-auto">' + p.name + '</div>'
                            + '<div class="row ml-auto my-auto mr-1 pt-2">'
                            + '<div class="input-group">'
                            + '<button type="button" class="btn btn-info btn-sm shadow-sm mr-2" href="#editProduct-modal" data-toggle="modal" onclick="editProductModal(' + p.id + ')">'
                            + '<i class="fa fa-edit mr-auto" style="font-size: 28px"></i>'
                            + '</button>'
                            + '</div>'
                            + '</div>'
                            + '</div>'
                            + '</div>'
                            + '</div>';
                }
                $('#publicProd-div')[0].innerHTML = innerhtml;
            }

            function changeTab(tab) {
                window.history.pushState(null, null, '${contextPath}?tab=' + tab);
            }

            changeTab('${currentTab}');
            showListCategories();
            showProductCategories();
            showProducts();
        </script>

        <footer class="footer font-small blue pt-3">
            <div class="p-3 mb-2 bg-dark text-white">
                Follow us on Github: <a href="https://github.com/AndreiDiaconu97/Shopping_Lists"> Shopping_Lists</a>
            </div>
        </footer>
    </body>
</html>
