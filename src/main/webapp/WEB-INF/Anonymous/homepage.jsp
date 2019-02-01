<%@page import="db.entities.List_anonymous"%>
<%@page import="db.daos.List_anonymousDAO"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.Set"%>
<%@page import="db.daos.jdbc.JDBC_utility.SortBy"%>
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
<%@page import="java.util.List"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="my" tagdir="/WEB-INF/tags" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="db.factories.DAOFactory"%>
<%@page import="db.exceptions.DAOFactoryException"%>
<%@page import="db.exceptions.DAOException"%>
<%@page import="db.entities.User"%>


<%!
    private UserDAO userDao;
    private List_anonymousDAO list_anonymousDao;
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
            list_anonymousDao = daoFactory.getDAO(List_anonymousDAO.class);
        } catch (DAOFactoryException ex) {
            throw new RuntimeException(new ServletException("Impossible to get the dao for list_anonymous", ex));
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
        if (list_anonymousDao != null) {
            list_anonymousDao = null;
        }
        if (list_catDao != null) {
            list_catDao = null;
        }
    }
%>
<%
    // check shopping list
    Cookie[] cookies = request.getCookies();
    String listID_s = null;
    for (Cookie c : cookies) {
        if (c.getName().equals("anonymous_list_ID")) {
            listID_s = c.getValue();
        }
    }

    // retrieve list
    List_anonymous list_anonymous = null;
    if (listID_s != null) {
        try {
            System.err.println("List_anonID: " + listID_s);
            Integer listID = Integer.parseInt(listID_s);
            list_anonymous = list_anonymousDao.getByPrimaryKey(listID);
            pageContext.setAttribute("list", list_anonymous);
        } catch (DAOException ex) {
            System.err.println("Error retrieving shopping list (jsp)" + ex);
            if (!response.isCommitted()) {
                response.sendRedirect("../error.html?error=");
            }
            return;
        }
    }

    pageContext.setAttribute("list_categories", list_catDao.getAll());
    System.err.println("Need to create list_anonymous = " + (list_anonymous == null));
    pageContext.setAttribute("need_create", list_anonymous == null);
    if (list_anonymous != null) {
        try {
            List<Prod_category> prod_categories = list_catDao.getProd_categories(list_anonymous.getCategory(), true);
            pageContext.setAttribute("prod_categories", prod_categories);

            List<Product> listProducts = list_anonymousDao.getProducts(list_anonymous);
            pageContext.setAttribute("listProducts", listProducts);

            JSONArray listProductsJSON = new JSONArray();
            boolean empty_missing = true;
            for (Product p : listProducts) {
                int purchased = list_anonymousDao.getAmountPurchased(list_anonymous, p);
                int total = list_anonymousDao.getAmountTotal(list_anonymous, p);
                Timestamp last_purchase = list_anonymousDao.getLastPurchase(list_anonymous, p);
                JSONObject pJSON = Product.toJSON(p);
                pJSON.put("purchased", purchased);
                pJSON.put("total", total);
                pJSON.put("last_purchase", last_purchase);
                listProductsJSON.put(pJSON);
                if (total != purchased) {
                    empty_missing = false;
                }
            }
            pageContext.setAttribute("listProductsJSON", listProductsJSON);
            System.err.println(listProductsJSON);
            pageContext.setAttribute("empty_missing", empty_missing);

            Set<Product> otherProducts = new HashSet<>();
            for (Prod_category p_c : prod_categories) {
                otherProducts.addAll(productDao.filterProducts(null, p_c, null, true, SortBy.POPULARITY));
            }
            otherProducts.removeAll(listProducts);
            pageContext.setAttribute("otherProductsJSON", Product.toJSON(otherProducts));
            pageContext.setAttribute("userDao", userDao);
            pageContext.setAttribute("list_anonymousDao", list_anonymousDao);
        } catch (DAOException ex) {
            System.err.println("Error getting some info: " + ex);
            response.sendRedirect("../error.html");
            return;
        }
    }
%>
<!DOCTYPE html>
<html>

    <head>
        <title>My list</title>
        <noscript>
        <META HTTP-EQUIV="Refresh" CONTENT="0;URL=../error.html?error=nojs">
        </noscript>
        <meta name="viewport" content="width=device-width, initial-scale=1" charset="UTF-8">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">
        <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.7.0/css/all.css" integrity="sha384-lZN37f5QGtY3VHgisS14W3ExzMWZxybE1SJSEsQp9S+oqd12jhcu+A56Ebc1zFSJ" crossorigin="anonymous">

        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"></script>
    </head>

    <body style="height: 100vh">
        <!-- navbar -->
        <nav class="navbar navbar-expand-md navbar-dark bg-dark sticky-top shadow">
            <!-- Title -->
            <a class="navbar-brand" href="homepage.html">
                <i class="fa fa-shopping-cart" style="font-size:30px"></i>
                My list
            </a>
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarSupportedContent">
                <ul class="nav navbar-nav ml-auto">              
                    <li class="dropdown ml-auto my-1">
                        <button class="btn btn-outline-secondary">
                            <a href="../registration.html" style="color: white; text-decoration: none"/>Sign-up</a>
                        </button>
                    </li>                            
                    <li class="dropdown ml-auto my-1">
                        <button class="btn btn-outline-secondary ml-2">
                            <a href="../login.html" style="color: white; text-decoration: none">Log-in</a>
                        </button>
                    </li>
                </ul>
            </div>
        </nav>

        <c:choose>
            <c:when test="${!need_create}">
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
                            <button type="button" class="btn btn-danger ml-auto" href="#listDeleteModal" data-toggle="modal">
                                <i class="fa fa-trash" style="font-size:20px"></i>
                            </button>
                            <button type="button" class="btn btn-secondary ml-2" href="#listSettingsModal" data-toggle="modal">
                                <i class="fa fa-cog" style="font-size:20px"></i>
                            </button>
                        </div>
                    </div>
                    <div class="row mx-auto">

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
                                            <button type="button" class="btn btn-primary ml-2 my-auto shadow rounded-circle" href="#addProductModal" data-toggle="modal">
                                                <i class="fa fa-plus mr-auto"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>




                <div class="container-fluid">
                    <c:if test="${!empty_missing}">
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
                    </c:if>

                    <!-- Missing products (not fully purchased) -->
                    <div id="missing-products">
                    </div>



                    <c:if test="${!empty_missing}">
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
                    </c:if>



                    <!-- Purchased products -->
                    <div id="purchased-products">
                    </div>
                </div>


                <!-- MODALS -->

                <!-- delete list modal -->
                <div class="modal modal-fluid" id="listDeleteModal">
                    <div class="modal-dialog modal-dialog-centered modal-sm">
                        <div class="modal-content">
                            <div class="modal-header shadow">
                                <i class="fa fa-exclamation-triangle my-auto mr-auto" style="font-size:25px; color: crimson"></i>
                                <h5 class="modal-title">Warning!</h5>
                                <button type="button" class="close" data-dismiss="modal">
                                    <span>&times;</span>
                                </button>
                            </div>
                            <div class="modal-body">
                                Delete this list definitely?
                            </div>
                            <div class="modal-footer form-horizontal">
                                <form action="anonymous.lists.handler" method="POST">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="list_id" value="${list.id}">
                                    <button type="submit" class="btn btn-danger">Confirm</button>
                                    <button type="button" class="btn btn-success" data-dismiss="modal">Cancel</button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- list settings -->
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
                                <form id="editListForm" action="anonymous.lists.handler" method="POST">
                                    <input type="hidden" name="list_id" value="${list.id}"/>
                                    <input type="hidden" name="action" value="edit"/>
                                    <div class="md-form mb-3">
                                        <i class="fa fa-bookmark prefix grey-text"></i>
                                        <label data-error="error" data-success="success">List name</label>
                                        <input type="text" class="form-control validate" name="name" value="${list.name}">
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
                            <div class="modal-body" id="otherProducts" style="height:65vh; overflow-y:scroll; width: 100%">
                            </div>

                            <div class="modal-footer">
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
                                <form id="add-Product-Form" action="anonymous.lists.handler" method="POST">
                                    <div class="input-group my-auto mr-auto" style="max-width: 200px">
                                        <input type="hidden" name="list_id"value="${list.id}">
                                        <input type="hidden" name="action" value="addProduct">
                                        <input type="hidden" id="add-Product-Hidden-Id" name="product_id">
                                        <input type="number" required id="add-Product-Form-Amount" class="form-control rounded shadow-sm my-auto" name="amount" placeholder="Amount">
                                        <button id="add-Product-Send-Btn" type="submit" onclick="submitAddProduct()" class="btn ml-2 btn-primary shadow rounded-circle">
                                            <i class="fa fa-plus"></i>
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- manage product -->
                <div class="modal" id="productManageModal">
                    <div class="modal-dialog modal-dialog-centered mx-auto" style="max-width: 400px">
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
                                <form id="manage-product-form" action="anonymous.lists.handler" method="POST">
                                    <div class="input-group mx-auto" id="manage-product-changeProductTotal" style="max-width: 300px" onclick="manageProduct('changeProductTotal')">
                                        <div class="input-group-prepend">
                                            <label id="manage-product-min" class="input-group-text" style="min-width: 50px">10</label>
                                        </div>
                                        <input type="number" id="manage-product-amount_input" class="form-control text-center rounded shadow-sm my-auto" style="appearance: none" name="amount" min="10" placeholder="10" onkeyup="mouseUpInput_check(this, 'manage-product-confirm')" onfocusout="focusOutInput_check(this, 'manage-product-confirm')">
                                    </div>
                                    <input type="hidden" name="list_id" value="${list.id}">
                                    <input id="manage-product-action" type="hidden" name="action">
                                    <input id="manage-product-product_id" type="hidden" name="product_id">
                                </form>
                                <button id="manage-product-removeProduct" type="button" class="btn btn-danger shadow-sm mx-auto my-2" onclick="manageProduct('removeProduct')">
                                    Remove product
                                    <i class="fa fa-trash mr-auto"></i>
                                </button>
                                <button id="manage-product-resetProduct" type="button" class="btn btn-danger shadow-sm mx-auto my-2" onclick="manageProduct('resetProduct')">
                                    Reset purchased
                                    <i class="fa fa-redo mr-auto"></i>
                                </button>
                            </div>
                            <div class="modal-footer">
                                <button id="manage-product-confirm" type="button" class="btn btn-primary" onclick="$('#manage-product-form')[0].submit()">Confirm<i class="fa fa-check ml-1"></i></button>
                                <button type="button" class="btn btn-danger" data-dismiss="modal">Cancel<i class="fa fa-times ml-1"></i></button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal modal-fluid"id="sendPurchasedModal">
                    <div class="modal-dialog modal-dialog-centered modal-sm">
                        <div class="modal-content">
                            <div class="modal-header shadow">
                                <h5 class="modal-title">Confirm purchases ?</h5>
                                <button type="button" class="close" data-dismiss="modal">
                                    <span>&times;</span>
                                </button>
                            </div>
                            <form id="sendPurchaseForm" action="anonymous.lists.handler" method="POST">
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

                    function mouseUpInput_check(input_bar, confirmBtn_id) {
                        if (!parseInt(input_bar.value) || (parseInt(input_bar.value) < parseInt(input_bar.min))) {
                            $('#' + confirmBtn_id)[0].disabled = true;
                        } else if ((parseInt(input_bar.max)) && (parseInt(input_bar.value) > parseInt(input_bar.max))) {
                            $('#' + confirmBtn_id)[0].disabled = true;
                        } else {
                            $('#' + confirmBtn_id)[0].disabled = false;
                        }
                    }
                    function focusOutInput_check(input_bar, confirmBtn_id) {
                        if (!parseInt(input_bar.value) || (parseInt(input_bar.value) < parseInt(input_bar.min)))
                            input_bar.value = input_bar.placeholder;
                        $('#' + confirmBtn_id)[0].disabled = false;
                    }

                    var listProducts = ${listProductsJSON};

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
                                    + '                <div id="input-group-edit-product' + p.id + '" class="input-group" style="width: 300px">'
                                    + (need_reset ? ('     <label class="input-group-text ml-auto" for="input-group-edit-product' + p.id + '" style="background-color: #F1C40F" data-toggle="tooltip" data-placement="top" title="It\'s been a while.\nReset suggested">'
                                            + '                <i class="fas fa-exclamation-triangle" style="font-size: 28px"></i>'
                                            + '            </label>') : '')
                                    + '                    <button type="button" id="modifyProdBtn' + p.id + '" class="btn btn-info btn-sm shadow-sm ' + (need_reset ? '' : 'ml-auto') + ' mr-2" data-toggle="modal" data-target="#productManageModal" onclick="fillProductManageModal(' + p.id + ')">'
                                    + '                       <i class="fa fa-edit mr-auto" style="font-size: 28px"></i>'
                                    + '                    </button>'
                                    + '                    <button type="button" id="leftBtn' + p.id + '" class="btn btn-secondary btn-sq-sm shadow-sm" disabled onmousedown="intervalClick(this,\'-\')">'
                                    + '                        <i class="fa fa-chevron-left mr-auto"></i>'
                                    + '                    </button>'
                                    + '                    <input type="number" id="prodAmount' + p.id + '" class="form-control text-center rounded shadow-sm my-auto" style="appearance: none; margin: 0"  name="quantity" min="' + p.purchased + '" max="' + p.total + '" value="' + p.purchased + '" placeholder="' + p.purchased + '" onfocusout="handleChange(this,' + p.id + ')"><br>'
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
                                    + '                <div id="input-group-edit-product' + p.id + '" class="input-group" style="width: 300px">'
                                    + (need_reset ? ('     <label class="input-group-text ml-auto" for="input-group-edit-product' + p.id + '" style="background-color: #F1C40F" data-toggle="tooltip" data-placement="top" title="It\'s been a while.\nReset suggested">'
                                            + '                <i class="fas fa-exclamation-triangle" style="font-size: 28px"></i>'
                                            + '            </label>') : '')
                                    + '                    <button type="button" id="modifyProdBtn' + p.id + '" class="btn btn-info btn-sm shadow-sm ' + (need_reset ? '' : 'ml-auto') + '" data-toggle="modal" data-target="#productManageModal" onclick="fillProductManageModal(' + p.id + ')">'
                                    + '                       <i class="fa fa-edit mr-auto" style="font-size: 28px"></i>'
                                    + '                    </button>'
                                    + '                </div>'
                                    + '            </div>'
                                    + '        </div>'
                                    + '    </div>'
                                    + '</div>';
                        }
                        $('#purchased-products')[0].innerHTML = purchasedhtml;
                    }

                    showProducts();

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
                                    + '    <div class="row my-2 ml-0">'
                                    + '        <img class="img-thumbnail mx-auto my-auto" style="width: 80px; height: 100%; min-width: 50px; min-height: 100%" alt="Responsive image" src="../images/products/' + p.id + '">'
                                    + '        <div class="col my-auto">'
                                    + '            <div class="text-left" style="font-size: 18px">'
                                    + '                ' + p.name
                                    + '            </div>'
                                    + '        </div>'
                                    + '    </div>'
                                    + '    <div class="row mx-0 justify-content-between">'
                                    + '        <div class="row mx-0 my-auto">'
                                    + '            <div class="input-group mb-3 my-auto" data-toggle="tooltip" data-placement="top" title="Rating: ' + p.rating.toString().substr(0, 3) + '">'
                                    + '                <i class="' + (p.rating >= 0.8 ? 'fas fa-star' : (p.rating >= 0.3 ? 'fa fa-star-half-alt' : 'far fa-star')) + '" style="font-size:21px;"></i>'
                                    + '                <i class="' + (p.num_votes > 0 ? (p.rating >= 1.8 ? 'fas fa-star' : (p.rating >= 1.3 ? 'fa fa-star-half-alt' : 'far fa-star')) : 'far fa-question-circle') + '" style="font-size:21px;"></i>'
                                    + '                <i class="' + (p.rating >= 2.8 ? 'fas fa-star' : (p.rating >= 2.3 ? 'fa fa-star-half-alt' : 'far fa-star')) + '" style="font-size:21px;"></i>'
                                    + '                <i class="' + (p.num_votes > 0 ? (p.rating >= 3.8 ? 'fas fa-star' : (p.rating >= 3.3 ? 'fa fa-star-half-alt' : 'far fa-star')) : 'far fa-question-circle') + '" style="font-size:21px;"></i>'
                                    + '                <i class="' + (p.rating >= 4.8 ? 'fas fa-star' : (p.rating >= 4.3 ? 'fa fa-star-half-alt' : 'far fa-star')) + '" style="font-size:21px;"></i>'
                                    + '            </div>'
                                    + '        </div>'
                                    + '        <div class="badge badge-pill badge-secondary shadow my-auto">' + p.category.name + '</div>'
                                    + '        <div class="text-left">Votes: ' + p.num_votes + '</div>'
                                    + '    </div>'
                                    + '    <hr>'
                                    + '    <div class="panel panel-success autocollapse">'
                                    + '        <div class="panel-heading clickable">'
                                    + '            <div class="row mx-auto">'
                                    + '                <p>Description</p>'
                                    + '                <i class="fa fa-chevron-circle-down ml-2" style="font-size:25px;"></i>'
                                    + '                <div class="text ml-auto mr-2" style="color: grey">created by</div>'
                                    + '                <div class="text" style="font-size: 18px">' + p.creator.firstname + ' ' + p.creator.lastname + '</div>'
                                    + '            </div>'
                                    + '        </div>'
                                    + '        <div class="panel-body">'
                                    + '            <div class="text-justify mx-4 mb-4">'
                                    + '                ' + p.description
                                    + '            </div>'
                                    + '        </div>'
                                    + '    </div>'
                                    + '</div>';
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
                            inputs += '<input type="hidden" name="product_id[]" value="' + p.id + '">';
                            inputs += '<input type="hidden" name="purchased_' + p.id + '" value="' + $('#prodAmount' + p.id)[0].value + '">';
                        }
                        $('#sendPurchaseForm')[0].innerHTML += inputs;
                        $('#sendPurchaseForm')[0].submit();
                    }
                </script>
            </c:when>
            <c:otherwise>
                <div class="container-fluid mt-3">
                    <button type="button" class="btn btn-grey shadow-lg rounded btn-block" style="height: 80vh;" href="#createListModal" data-toggle="modal">          
                        <img class="img-fluid" src="../images/plus_button" style="max-height: 80%">
                    </button>
                </div>


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
                            <form id="createListForm" action="anonymous.lists.handler" method="POST">
                                <input type="hidden" name="tab" value="mylists" id="tab-input-0"/>
                                <input type="hidden" name="action" value="create"/>
                                <div class="modal-body mx-3">
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
                                    <button type="button" class="btn btn-primary" data-dismiss="modal" onclick="$(createListForm)[0].submit()">Confirm</button> 
                                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <%@include file="../sharedHtml/footer.html" %>
            </c:otherwise>
        </c:choose>

    </body>

</html>