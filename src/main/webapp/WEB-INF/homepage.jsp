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
        getServletContext().log("homepage.html is already committed");
    }

    String contextPath = getServletContext().getContextPath();
    if (!contextPath.endsWith("/")) {
        contextPath += "/";
    }

    User user = null;
    if (session != null) {
        user = (User) session.getAttribute("user");
    }
    if (user == null) {
        if (!response.isCommitted()) {
            response.sendRedirect(response.encodeRedirectURL(contextPath + "login.html"));
        }
    }

    List<List_reg> myLists;
    List<List_reg> sharedLists;
    List<List_category> categories;
    try {
        myLists = userDao.getOwnedLists(user);
        sharedLists = userDao.getSharedLists(user);
        categories = list_catDao.getAll();
        pageContext.setAttribute("myLists", myLists);
        pageContext.setAttribute("sharedLists", sharedLists);
        pageContext.setAttribute("categories", categories);
        pageContext.setAttribute("list_catDao", list_catDao);
        pageContext.setAttribute("list_regDao", list_regDao);
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
        <meta name="viewport" content="width=device-width, initial-scale=1" charset="UTF-8">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    </head>
    <body>
        <nav class="navbar navbar-expand-md navbar-dark bg-dark sticky-top shadow">
            <a class="navbar-brand " href="homepage.html">
                <i class="fa fa-shopping-cart" style="font-size:30px"></i>
                Shopping lists
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
                <a class="nav-item nav-link my-auto active" id="myLists-tab" data-toggle="tab" href="#nav-myLists" role="tab" aria-controls="nav-myLists" aria-selected="true">
                    <h5>my lists</h5>
                </a>
                <a class="nav-item nav-link my-auto mx-1" id="sharedLists-tab" data-toggle="tab" href="#nav-sharedLists" role="tab" aria-controls="nav-sharedLists" aria-selected="false">
                    <h5>shared with me</h5>
                </a>
                <a class="nav-item nav-link my-auto" id="sharedLists-tab" data-toggle="tab" href="#nav-myProducts" role="tab" aria-controls="nav-myProducts" aria-selected="false">
                    <h5>my products</h5>
                </a>
            </div>
        </nav>
        <div class="tab-content" id="nav-tabContent">
            <div class="tab-pane fade show active" id="nav-myLists" role="tabpanel" aria-labelledby="nav-myLists">
                <div class="row  mx-1">
                    <div class="row ml-auto mr-1 mt-2">
                        <div class="row ml-2 mr-0 my-2">
                            <div class="input-group my-auto">
                                <select class="custom-select">
                                    <option value="-1" selected>sort by</option>
                                    <option value="0">name [a-Z]</option>
                                    <option value="1">name [Z-a]</option>
                                </select>
                            </div>
                        </div>
                        <div class="row mx-2 my-2">
                            <div class="input-group my-auto">
                                <select class="custom-select">
                                    <option value="-1" selected>all categories</option>
                                    <option value="0">category 1</option>
                                    <option value="1">category 2</option>
                                </select>
                            </div>
                        </div>
                        <div class="row ml-auto mx-2 my-2">
                            <div class="input-group">                            
                                <input class="form-control" type="search" placeholder="your shopping lists..." aria-label="Search">
                                <button class="btn btn-outline-success" type="submit">
                                    <i class="fa fa-search mr-auto" style="font-size:20px;"></i>
                                </button>   
                                <button type="button" class="btn btn-primary ml-2 my-auto shadow rounded-circle" href="#createListModal" data-toggle="modal">          
                                    <i class="fa fa-plus mr-auto"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row justify-content-center mx-auto">
                    <c:forEach var="list" items="${myLists}" varStatus="i">
                        <a href="shopping.list.html?shop_listID=${list.id}" class="my-3 mx-4">
                            <div class="card text-dark" style="width: 16rem; display: inline-block">
                                <div class="card-header" style="font-weight: bold">
                                    <c:out value="${list.name}"/>
                                </div>
                                <img class="card-img-top" src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Logo-Free.jpg" alt="Card image cap">
                                <div class="card-footer text-muted">
                                    <c:out value="${list.category.name}"/>
                                    <span class="badge badge-pill badge-secondary float-right">3/7</span>
                                </div>
                            </div>
                        </a>
                    </c:forEach>
                </div>
            </div>
            <div class="tab-pane fade" id="nav-sharedLists" role="tabpanel" aria-labelledby="nav-sharedLists">
                <div class="row  mx-1">
                    <div class="row ml-auto mr-1 mt-2">
                        <div class="row ml-2 mr-0 my-2">
                            <div class="input-group my-auto">
                                <select class="custom-select">
                                    <option value="-1" selected>sort by</option>
                                    <option value="0">name [a-Z]</option>
                                    <option value="1">name [Z-a]</option>
                                </select>
                            </div>
                        </div>
                        <div class="row mx-2 my-2">
                            <div class="input-group my-auto">
                                <select class="custom-select">
                                    <option value="-1" selected>all categories</option>
                                    <option value="0">category 1</option>
                                    <option value="1">category 2</option>
                                </select>
                            </div>
                        </div>
                        <div class="row ml-auto mx-2 my-2">
                            <div class="input-group">                            
                                <input class="form-control" type="search" placeholder="shared shopping lists..." aria-label="Search">
                                <button class="btn btn-outline-success" type="submit">
                                    <i class="fa fa-search mr-auto" style="font-size:20px;"></i>
                                </button>   
                                <button type="button" class="btn btn-primary ml-2 my-auto shadow rounded-circle" href="#importListModal" data-toggle="modal">          
                                    <i class="fa fa-plus mr-auto"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row justify-content-center mx-auto">
                    <c:forEach var="list" items="${sharedLists}" varStatus="i">
                        <a href="shopping.list.html?shop_listID=${list.id}" class="my-3 mx-4">
                            <div class="card text-dark" style="width: 16rem; display: inline-block">
                                <div class="card-header" style="font-weight: bold">
                                    <c:out value="${list.name}"/>
                                </div>
                                <img class="card-img-top" src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Logo-Free.jpg" alt="Card image cap">
                                <div class="card-body" style="font-size: 15px; text-align: right">
                                    <c:out value="${list.owner.email}"/>
                                    <i class="fa fa-user" style="font-size:20px;"></i>
                                </div>
                                <div class="card-footer text-muted">
                                    <c:out value="${list.category.name}"/>
                                    <span class="badge badge-pill badge-secondary float-right">3/7</span>
                                </div>
                            </div>
                        </a>
                    </c:forEach>
                </div>
            </div>
            <div class="tab-pane fade" id="nav-myProducts" role="tabpanel" aria-labelledby="nav-myProducts">
                <div class="row  mx-1">
                    <div class="row ml-auto mr-1 mt-2">
                        <div class="row ml-2 mr-0 my-2">
                            <div class="input-group my-auto">
                                <select class="custom-select">
                                    <option value="-1" selected>sort by</option>
                                    <option value="0">name [a-Z]</option>
                                    <option value="1">name [Z-a]</option>
                                    <option value="2">rating ++</option>
                                    <option value="3">rating --</option>
                                    <option value="4">popularity ++</option>
                                    <option value="5">popularity --</option>
                                </select>
                            </div>
                        </div>
                        <div class="row mx-2 my-2">
                            <div class="input-group my-auto">
                                <select class="custom-select">
                                    <option value="-1" selected>all categories</option>
                                    <option value="0">category 1</option>
                                    <option value="1">category 2</option>
                                </select>
                            </div>
                        </div>
                        <div class="row ml-auto mx-2 my-2">
                            <div class="input-group">                            
                                <input class="form-control" type="search" placeholder="your products..." aria-label="Search">
                                <button class="btn btn-outline-success" type="submit">
                                    <i class="fa fa-search mr-auto" style="font-size:20px;"></i>
                                </button>   
                                <button type="button" class="btn btn-primary ml-2 my-auto shadow rounded-circle" href="#createProductModal" data-toggle="modal">          
                                    <i class="fa fa-plus mr-auto"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- add products -->
                <div class="row">

                </div>
            </div>
        </div>
    </div>

    <!-- MODALS -->
    
    <!-- create list -->
    <div class="modal modal-fluid" id="createListModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header shadow">
                    <i class="fa fa-cart-plus my-auto mr-auto" style="font-size:30px;"></i>
                    <h5 class="modal-title">Create a list</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    
                </div>
                <div class="modal-footer form-horizontal">
                    <button type="button" class="btn btn-primary" data-dismiss="modal">Confirm changes</button> 
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- import list -->
    <div class="modal modal-fluid" id="importListModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header shadow">
                    <i class="fa fa-cart-plus my-auto mr-auto" style="font-size:30px;"></i>
                    <h5 class="modal-title">Import friend's lists</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    
                </div>
                <div class="modal-footer form-horizontal">
                    <button type="button" class="btn btn-primary" data-dismiss="modal">Confirm changes</button> 
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- create product -->
    <div class="modal modal-fluid" id="createProductModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header shadow">
                    <i class="fa fa-cart-plus my-auto mr-auto" style="font-size:30px;"></i>
                    <h5 class="modal-title">Create a product</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    
                </div>
                <div class="modal-footer form-horizontal">
                    <button type="button" class="btn btn-primary" data-dismiss="modal">Confirm changes</button> 
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </div>
    
    <footer class="footer font-small blue pt-3">
        <div class="p-3 mb-2 bg-dark text-white">
            Follow us on Github: <a href="https://github.com/AndreiDiaconu97/Shopping_Lists"> Shopping_Lists</a>
        </div>
    </footer>

    <!-- Bootstrap core JavaScript ================================================== -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"></script>
</body>
</html>

