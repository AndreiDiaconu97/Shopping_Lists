<%@page import="db.daos.Prod_categoryDAO"%>
<%@page import="db.entities.Prod_category"%>
<%@page import="db.entities.List_category"%>
<%@page import="java.util.List"%>
<%@page import="db.entities.User"%>
<%@page import="db.exceptions.DAOFactoryException"%>
<%@page import="db.factories.DAOFactory"%>
<%@page import="db.daos.List_categoryDAO"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    private List_categoryDAO list_catDao;

    public void jspInit() {
        DAOFactory daoFactory = (DAOFactory) super.getServletContext().getAttribute("daoFactory");
        if (daoFactory == null) {
            throw new RuntimeException(new ServletException("Impossible to get dao factory"));
        }
        try {
            list_catDao = daoFactory.getDAO(List_categoryDAO.class);
        } catch (DAOFactoryException ex) {
            throw new RuntimeException(new ServletException("Impossible to get the dao for list_cat", ex));
        }
    }

    public void jspDestroy() {
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

    String currentTab = "linkedProductCats";
    if ("otherProductCats".equals(request.getParameter("tab"))) {
        currentTab = request.getParameter("tab");
    }
    pageContext.setAttribute("currentTab", currentTab);

    // check list category id
    String list_cat_Param = request.getParameter("list_catID");
    if ((list_cat_Param == null) || (list_cat_Param.equals(""))) {
        if (!response.isCommitted()) {
            response.sendRedirect(response.encodeRedirectURL(contextPath + "admin/admin.html"));
        }
        return;
    }
    Integer list_cat_ID = Integer.parseInt(list_cat_Param);
    pageContext.setAttribute("list_cat_ID", list_cat_ID);

    List_category list_cat;
    List<Prod_category> own_prod_categories;
    List<Prod_category> other_prod_categories;
    try {
        list_cat = list_catDao.getByPrimaryKey(list_cat_ID);
        own_prod_categories = list_catDao.getProd_categories(list_cat, true);
        other_prod_categories = list_catDao.getProd_categories(list_cat, false);
        pageContext.setAttribute("list_cat", list_cat);
        pageContext.setAttribute("own_prod_categories", own_prod_categories);
        pageContext.setAttribute("other_prod_categories", other_prod_categories);
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
        <title>List category manager</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" charset="UTF-8">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
        <!-- Bootstrap core JavaScript ================================================== -->
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
                        <form class="form-inline" action="<%=contextPath%>auth" method="POST">
                            <input class="form-control" type="hidden" name="action" value="logout" required>
                            <button type="submit" class="btn btn-outline-secondary btn-sm">Logout</button>
                        </form>
                    </li>
                </ul>
            </div>
        </nav>
        <main role="main">
            <div class="jumbotron shadow-sm">
                <div class="container-fluid">
                    <h3 class="display-3">Manage "${list_cat.name}"</h3>
                    <p>Assign or remove products categories from this list category.</p>
                </div>
            </div>
        </main>

        <!-- description spoiler -->
        <div class="container-fluid mb-4">
            <div class="panel panel-success autocollapse">
                <div class="panel-heading clickable">
                    <div class="row mx-auto">
                        <i class="fa fa-chevron-circle-down mr-2 my-auto" style="font-size:20px;"></i>
                        <div class="text-left my-auto">Description</div>
                    </div>
                </div>
                <div class="panel-body">
                    <hr>
                    <div class="text-justify mx-4">
                        <c:out value="(${list_cat.description})"/>
                    </div>
                </div>
            </div>
        </div>
        <nav>
            <div class="nav nav-tabs nav-justified" id="myTab" role="tablist">
                <a class="nav-item nav-link my-auto <c:if test="${currentTab.equals('linkedProductCats')}">active</c:if>" data-toggle="tab" href="#nav-ownListCategories" role="tab" onclick="changeTab('linkedProductCats')">
                        <h5>Linked product categories</h5>
                    </a>
                    <a class="nav-item nav-link my-auto mx-1 <c:if test="${currentTab.equals('otherProductCats')}">active</c:if>" data-toggle="tab" href="#nav-otherListCategories" role="tab" onclick="changeTab('otherProductCats')">
                        <h5>Other product categories</h5>
                    </a>
                </div>
            </nav>
            <div class="tab-content" id="nav-tabContent">
                <!-- List categories -->
                <div class="tab-pane fade <c:if test="${currentTab.equals('linkedProductCats')}">show active</c:if>" id="nav-ownListCategories" role="tabpanel" aria-labelledby="nav-listCategories">
                    <div class="container-fluid shadow mb-3">
                        <div class="row justify-content-end">
                            <div class="row ml-0 mr-0 my-2">
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
                            <div class="row ml-1 mr-3 my-2">
                                <div class="input-group">                            
                                    <input class="form-control" type="search" placeholder="product categories..." aria-label="Search">
                                    <button class="btn btn-outline-success" type="submit">
                                        <i class="fa fa-search mr-auto" style="font-size:20px;"></i>
                                    </button>   
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="container-fluid">
                        <div class="row mx-auto mb-2 justify-content-end">
                            <button type="button" class="btn btn-success mr-2 my-auto shadow rounded border" onclick="$('#unlinkProdCat-form').submit()">  
                                Update
                                <i class="fa fa-check ml-1"></i>
                            </button>
                            <button type="button" class="btn btn-danger my-auto shadow rounded" onclick="resetParameters('unlink')">  
                                Cancel
                                <i class="fa fa-times ml-1"></i>
                            </button>
                        </div>
                        <hr>
                        <form id="unlinkProdCat-form" action="${contextPath}admin.handler" method="POST">
                        <input type="hidden" name="tab" value="linkedProductCats"/>
                        <input type="hidden" name="action" value="listproductcat"/>
                        <input type="hidden" name="list_cat" value="${list_cat.id}"/>
                        <c:forEach var="prod_cat" items="${own_prod_categories}">
                            <div class="card shadow-sm mb-2">
                                <div class="card-body">
                                    <div class="row">
                                        <img class="img-thumbnail shadow-sm mx-2" style="width: 70px; height: 100%; min-width: 50px; min-height: 100%" alt="Responsive image" src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Logo-Free.jpg">
                                        <p class="mr-2 my-auto">${prod_cat.name}</p>
                                        <input type="hidden" id="unlinkProdCat-toggle${prod_cat.id}" name="" value="${prod_cat.id}"/>
                                        <button type="button" id="unlinkProdCat-button${prod_cat.id}" class="btn btn-danger my-auto ml-auto mr-2 shadow-sm rounded" data-toggle="button" onclick="toggleParameter('unlink',${prod_cat.id})">
                                            <i class="fa fa-trash"></i>
                                        </button>
                                    </div>
                                    <hr>
                                    <div class="panel panel-success autocollapse ml-2">
                                        <div class="panel-heading clickable">
                                            <div class="row">
                                                <div class="text-left my-auto">Description</div>
                                                <i class="fa fa-chevron-circle-down my-auto mx-2" style="font-size:20px;"></i>
                                            </div>
                                        </div>
                                        <div class="panel-body">
                                            <hr>
                                            <div class="text-justify mx-4">
                                                ${prod_cat.description}
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach> 
                    </form>
                    <hr>
                    <div class="row mx-auto mb-2 justify-content-end">
                        <button type="button" class="btn btn-success mr-2 my-auto shadow rounded border" onclick="$('#unlinkProdCat-form').submit()">  
                            Update
                            <i class="fa fa-check ml-1"></i>
                        </button>
                        <button type="button" class="btn btn-danger my-auto shadow rounded" onclick="resetParameters('unlink')">  
                            Cancel
                            <i class="fa fa-times ml-1"></i>
                        </button>
                    </div>
                </div>
            </div>
            <div class="tab-pane fade <c:if test="${currentTab.equals('otherProductCats')}">show active</c:if>" id="nav-otherListCategories" role="tabpanel" aria-labelledby="nav-prodCategories">
                    <div class="container-fluid shadow mb-3">
                        <div class="row justify-content-end">
                            <div class="row ml-0 mr-0 my-2">
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
                            <div class="row ml-1 mr-3 my-2">
                                <div class="input-group">                            
                                    <input class="form-control" type="search" placeholder="product categories..." aria-label="Search">
                                    <button class="btn btn-outline-success" type="submit">
                                        <i class="fa fa-search mr-auto" style="font-size:20px;"></i>
                                    </button>   
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="container-fluid">
                        <div class="row mx-auto mb-2 justify-content-end">
                            <button type="button" class="btn btn-success mr-2 my-auto shadow rounded border" onclick="$('#linkProdCat-form').submit()">  
                                Update
                                <i class="fa fa-check ml-1"></i>
                            </button>
                            <button type="button" class="btn btn-danger my-auto shadow rounded" onclick="resetParameters('link')">  
                                Cancel
                                <i class="fa fa-times ml-1"></i>
                            </button>
                        </div>
                        <hr>
                        <form id="linkProdCat-form" action="${contextPath}admin.handler" method="POST">
                        <input type="hidden" name="tab" value="otherProductCats"/>
                        <input type="hidden" name="action" value="listproductcat"/>
                        <input type="hidden" name="list_cat" value="${list_cat.id}"/>
                        <c:forEach var="prod_cat"  items="${other_prod_categories}">
                            <div class="card shadow-sm mb-2">
                                <div class="card-body">
                                    <div class="row">
                                        <img class="img-thumbnail shadow-sm mx-2" style="width: 70px; height: 100%; min-width: 50px; min-height: 100%" alt="Responsive image" src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Logo-Free.jpg">
                                        <p class="mr-2 my-auto">${prod_cat.name}</p>
                                        <input type="hidden" id="linkProdCat-toggle${prod_cat.id}" name="" value="${prod_cat.id}"/>
                                        <button type="button" id="linkProdCat-button${prod_cat.id}" class="btn btn-primary my-auto ml-auto mr-2 shadow-sm rounded-circle" data-toggle="button" onclick="toggleParameter('link',${prod_cat.id})">
                                            <i class="fa fa-plus"></i>
                                        </button>
                                    </div>
                                    <hr>
                                    <div class="panel panel-success autocollapse ml-2">
                                        <div class="panel-heading clickable">
                                            <div class="row mx">
                                                <div class="text-left my-auto">Description</div>
                                                <i class="fa fa-chevron-circle-down my-auto mx-2" style="font-size:20px;"></i>
                                            </div>
                                        </div>
                                        <div class="panel-body">
                                            <hr>
                                            <div class="text-justify mx-4">
                                                ${prod_cat.description}
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach> 
                    </form>
                    <hr>
                    <div class="row mx-auto mb-2 justify-content-end">
                        <button type="button" class="btn btn-success mr-2 my-auto shadow rounded border" onclick="$('#linkProdCat-form').submit()">  
                            Update
                            <i class="fa fa-check ml-1"></i>
                        </button>
                        <button type="button" class="btn btn-danger my-auto shadow rounded" onclick="resetParameters('link')">  
                            Cancel
                            <i class="fa fa-times ml-1"></i>
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <script>
            var own_prod_categories = ${Prod_category.toJSON(own_prod_categories)};
            var other_prod_categories = ${Prod_category.toJSON(other_prod_categories)};

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

            function toggleParameter(action, prodCat_ID) {
                let inputElement;
                if (action === 'link') {
                    inputElement = $('#linkProdCat-toggle' + prodCat_ID)[0];
                    if (inputElement.name === '') {
                        inputElement.name = 'prod_category_add';
                    } else {
                        inputElement.name = '';
                    }
                } else if (action === 'unlink') {
                    inputElement = $('#unlinkProdCat-toggle' + prodCat_ID)[0];
                    if (inputElement.name === '') {
                        inputElement.name = 'prod_category_rem';
                    } else {
                        inputElement.name = '';
                    }
                }
            }

            function resetParameters(action) {
                let prod_categories;
                if (action === 'link') {
                    prod_categories = other_prod_categories;
                } else if (action === 'unlink') {
                    prod_categories = own_prod_categories;
                } else {
                    return;
                }

                for (var prodCat of prod_categories) {
                    console.log(prodCat);
                    console.log("BUTTON: " + $('#' + action + 'ProdCat-button' + prodCat.id)[0].id);
                    if ($('#' + action + 'ProdCat-toggle' + prodCat.id)[0].name !== '') {
                        $('#' + action + 'ProdCat-button' + prodCat.id)[0].click();
                    }
                }
            }

            function changeTab(tab) {
                window.history.pushState(null, null, '${contextPath}list.cat.html?list_catID=${list_cat_ID}&tab=' + tab);
            }
            changeTab('${currentTab}');
        </script>

        <footer class="footer font-small blue pt-3">
            <div class="p-3 mb-2 bg-dark text-white">
                Follow us on Github: <a href="https://github.com/AndreiDiaconu97/Shopping_Lists"> Shopping_Lists</a>
            </div>
        </footer>
    </body>
</html>
