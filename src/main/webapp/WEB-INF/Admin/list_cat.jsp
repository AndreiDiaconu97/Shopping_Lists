<%@page import="db.exceptions.DAOException"%>
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

    String currentTab = "linkedProductCats";
    if ("otherProductCats".equals(request.getParameter("tab"))) {
        currentTab = request.getParameter("tab");
    }
    pageContext.setAttribute("currentTab", currentTab);
    
    // check list category id
    String list_cat_Param = request.getParameter("list_catID");
    if ((list_cat_Param == null) || (list_cat_Param.equals(""))) {
        if (!response.isCommitted()) {
            response.sendRedirect(response.encodeRedirectURL("admin.html"));
        }
        return;
    }
    Integer list_cat_ID = Integer.parseInt(list_cat_Param);
    pageContext.setAttribute("list_cat_ID", list_cat_ID);
    
    // retrieve list category
        List_category list_cat;
    try {
        list_cat = list_catDao.getByPrimaryKey(list_cat_ID);
                pageContext.setAttribute("list_cat", list_cat);
    } catch (DAOException ex) {
        System.err.println("Error retrieving list category (jsp)" + ex);
        if (!response.isCommitted()) {
            response.sendRedirect("../error.html?error=");
        }
        return;
    }
    if (list_cat == null) {
        System.err.println("List category not found");
        if (!response.isCommitted()) {
            response.sendRedirect(response.encodeRedirectURL("admin.html"));
        }
        return;
    }

    List<Prod_category> own_prod_categories;
    List<Prod_category> other_prod_categories;
    try {
        own_prod_categories = list_catDao.getProd_categories(list_cat, true);
        other_prod_categories = list_catDao.getProd_categories(list_cat, false);
        pageContext.setAttribute("own_prod_categories", own_prod_categories);
        pageContext.setAttribute("other_prod_categories", other_prod_categories);
    } catch (Exception ex) {
        System.err.println("Error loading admin (jsp)" + ex);
        if (!response.isCommitted()) {
            response.sendRedirect("../error.html?error=");
        }
    }

%>

<!DOCTYPE html>
<html>
    <head>
        <title>List category manager</title>
        <noscript>
        <META HTTP-EQUIV="Refresh" CONTENT="0;URL=../error.html?error=nojs">
        </noscript>
        <meta name="viewport" content="width=device-width, initial-scale=1" charset="UTF-8">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
        <!-- Bootstrap core JavaScript ================================================== -->
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"></script>

        <style>
            .greyBtn{
                background-color: #777777
            }
        </style>
    </head>
    <body>

        <%@include file="../sharedHtml/navbar.html" %>

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
                                    <select class="custom-select" id="linkedProdCat-search-sort" onchange="showProductCategories('linked')">
                                        <option value="Name">Name</option>
                                        <option value="Renew time >">Renew time ></option>
                                        <option value="Renew time <">Renew time <</option>
                                    </select>
                                </div>
                            </div>
                            <div class="row ml-1 mr-3 my-2">
                                <div class="input-group">                            
                                    <input class="form-control" type="search" placeholder="product categories..." aria-label="Search" id="linkedProdCat-search-name"  onkeyup="showProductCategories('linked')">
                                    <div class="input-group-append">
                                        <label class="input-group-text rounded">
                                            <i class="fa fa-search"></i>
                                        </label>
                                    </div>     
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="container-fluid">
                        <!-- load own product categories -->
                        <form id="unlinkProdCat-form" action="admin.handler" method="POST"></form>
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
                                    <select class="custom-select" id="otherProdCat-search-sort" onchange="showProductCategories('other')">
                                        <option value="Name">Name</option>
                                        <option value="Renew time >">Renew time ></option>
                                        <option value="Renew time <">Renew time <</option>
                                    </select>
                                </div>
                            </div>
                            <div class="row ml-1 mr-3 my-2">
                                <div class="input-group">                            
                                    <input class="form-control" type="search" placeholder="product categories..." aria-label="Search" id="otherProdCat-search-name"  onkeyup="showProductCategories('other')">
                                    <div class="input-group-append">
                                        <label class="input-group-text rounded">
                                            <i class="fa fa-search"></i>
                                        </label>
                                    </div>   
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="container-fluid">
                        <!-- load other product categories -->
                        <form id="linkProdCat-form" action="admin.handler" method="POST"></form>
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

            function hideDescription() {
                var $classy = '.panel.autocollapse';
                var $found = $($classy);
                $found.find('.panel-body').hide();
                $found.removeClass($classy);
            }
            $(document).ready(hideDescription());

            function toggleParameter(action, prodCat_ID) {
                let inputElement;
                if (action === 'link') {
                    inputElement = $('#linkProdCat-toggle' + prodCat_ID)[0];
                    if (inputElement.name === '') {
                        inputElement.name = 'prod_category_add';
                        inputElement.style.color
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

            function showProductCategories(which) {
                let sortby = $('#' + which + 'ProdCat-search-sort')[0].value;
                let name = $('#' + which + 'ProdCat-search-name')[0].value;

                let btnAction;
                let prodCategories;
                switch (which) {
                    case 'linked':
                        prodCategories = own_prod_categories.slice();
                        btnAction = 'unlink';
                        break;
                    case 'other':
                    default:
                        prodCategories = other_prod_categories.slice();
                        btnAction = 'link';
                        break;
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
                let innerhtml = ''
                        + '<input type="hidden" name="tab" value="' + which + 'ProductCats"/>'
                        + '<input type="hidden" name="action" value="listproductcat"/>'
                        + '<input type="hidden" name="list_cat" value="${list_cat.id}"/>';
                for (prod_cat of prodCategories) {
                    innerhtml = innerhtml
                            + '<div class="card shadow-sm mb-2">'
                            + '<div class="card-body">'
                            + '<div class="row">'
                            + '<img class="img-thumbnail shadow-sm mx-2" style="width: 70px; height: 100%; min-width: 50px; min-height: 100%" alt="Responsive image" src="../images/product_categories/' + prod_cat.id + '">'
                            + '<p class="mr-2 my-auto">' + prod_cat.name + '</p>'
                            + '<input type="hidden" id="' + btnAction + 'ProdCat-toggle' + prod_cat.id + '" name="" value="' + prod_cat.id + '"/>'
                            + '<button type="button" id="' + btnAction + 'ProdCat-button' + prod_cat.id + '" class="btn btn-' + (btnAction === 'link' ? 'primary rounded-circle' : 'danger rounded') + ' my-auto ml-auto mr-2 shadow-sm greyBtn" data-toggle="button" onclick="toggleParameter(\'' + btnAction + '\',' + prod_cat.id + ')">'
                            + '<i class="fa fa-' + (btnAction === 'link' ? 'plus' : 'trash') + '"></i>'
                            + '</button>'
                            + '</div>'
                            + '<hr>'
                            + '<div class="panel panel-success autocollapse ml-2">'
                            + '<div class="panel-heading clickable">'
                            + '<div class="row">'
                            + '<div class="text-left my-auto">Description</div>'
                            + '<i class="fa fa-chevron-circle-down my-auto mx-2" style="font-size:20px;"></i>'
                            + '</div>'
                            + '</div>'
                            + '<div class="panel-body">'
                            + '<hr>'
                            + '<div class="text-justify mx-4">' + prod_cat.description + '</div>'
                            + '</div>'
                            + '</div>'
                            + '</div>'
                            + '</div>';
                }
                $('#' + btnAction + 'ProdCat-form')[0].innerHTML = innerhtml;
                hideDescription();
            }

            function changeTab(tab) {
                window.history.pushState(null, null, 'list.cat.html?list_catID=${list_cat_ID}&tab=' + tab);
            }
            changeTab('${currentTab}');
            showProductCategories('linked');
            showProductCategories('other');
        </script>

        <%@include file="../sharedHtml/footer.html" %>
    </body>
</html>
