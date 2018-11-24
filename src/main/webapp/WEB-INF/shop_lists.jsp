<%@page import="db.entities.Product"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="db.entities.List_category"%>
<%@page import="db.daos.List_categoryDAO"%>
<%@page import="db.entities.List_reg"%>
<%@page import="db.daos.List_regDAO"%>
<%@page import="java.util.List"%>
<%@page import="db.exceptions.DAOException"%>
<%@page import="db.daos.List_regDAO"%>
<%@page import="db.entities.Reg_User"%>
<%@page import="db.exceptions.DAOFactoryException"%>
<%@page import="db.factories.DAOFactory"%>
<%@page import="db.daos.Reg_UserDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    private Reg_UserDAO reg_userDao;
    private List_regDAO list_regDao;
    private List_categoryDAO list_catDao;

    public void jspInit() {
        DAOFactory daoFactory = (DAOFactory) super.getServletContext().getAttribute("daoFactory");
        if (daoFactory == null) {
            throw new RuntimeException(new ServletException("Impossible to get dao factory"));
        }
        try {
            reg_userDao = daoFactory.getDAO(Reg_UserDAO.class);
        } catch (DAOFactoryException ex) {
            throw new RuntimeException(new ServletException("Impossible to get dao for reg_user", ex));
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
        if (reg_userDao != null) {
            reg_userDao = null;
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
        getServletContext().log("shopping.lists.html is already committed");
    }
    String contextPath = getServletContext().getContextPath();
    if (!contextPath.endsWith("/")) {
        contextPath += "/";
    }

    Reg_User reg_user = null;
    if (session != null) {
        reg_user = (Reg_User) session.getAttribute("reg_user");
    }

    if (reg_user == null) {
        if (!response.isCommitted()) {
            response.sendRedirect(response.encodeRedirectURL(contextPath + "login.html"));
        }
    }

    List<List_reg> myLists;
    List<List_reg> sharedLists;
    List<List_category> categories;
    try {
        myLists = reg_userDao.getOwningShopLists(reg_user);
        sharedLists = reg_userDao.getSharedShopLists(reg_user);
        categories = list_catDao.getAll();
        pageContext.setAttribute("myLists", myLists);
        pageContext.setAttribute("sharedLists", sharedLists);
        pageContext.setAttribute("categories", categories);
        pageContext.setAttribute("list_catDao", list_catDao);
        pageContext.setAttribute("list_regDao", list_regDao);
        pageContext.setAttribute("reg_userDao", reg_userDao);
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
        <title>My lists</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" charset="UTF-8">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"></script>
    </head>
    <body>
        <div class="container">
            <div class="row">
                <h1>Shopping lists manager</h1>
            </div>
            <div class="text-right">
                logged in as <b>${reg_user.email}</b><br>
                <form action="<%=contextPath%>auth" method="POST">
                    <input type="hidden" name="action" value="logout" required>
                    <button type="submit" class="btn btn-outline-secondary btn-sm">Logout</button>
                </form>
            </div>     
            <div class ="row">
                <div class ="col-sm">
                    <p class="text-center font-weight-bold">
                        All lists
                    </p>
                    <!-- print user's lists -->
                    <c:forEach var='list' items='${myLists}'>
                        <button class='btn' data-toggle='collapse' data-target='#collapse${list.id}'>
                            ${list.getName()} (Id: ${list.id})
                        </button><br>
                        <div id='collapse${list.id}' class='collapse'>
                            Author: ${reg_userDao.getByPrimaryKey(list.owner).email}<br>
                            Description: ${list.description}<br>
                            Category: ${list.category}<br>
                            Products
                            <ul>
                                <c:forEach var='product' items='${list_regDao.getProducts(list)}'>
                                    <li>${product.getName()}
                                    </li>
                                </c:forEach>
                            </ul>
                            <button class="btn" data-toggle='modal' data-target='#editListModal' onclick='
                                    document.getElementById("editModalListName").value = "${list.name}";
                                    document.getElementById("editListModalTitle").innerHTML = "Edit ${list.name}";
                                    document.getElementById("editDescriptionInput").value = "${list.description}";
                                    document.getElementById("editModalListID").value = ${list.id};
                                    document.getElementById("editCategorySelect").selectedIndex = "${categories.indexOf(list_catDao.getByPrimaryKey(list.category))}";
                                    '>
                                edit
                            </button>
                            <form action="shopping.lists.handler" method="POST">
                                <input type="hidden" name="list_id" value='${list.id}'>
                                <input type="hidden" name="action" value="delete">
                                <button type="submit" class='btn btn-primary'>Delete</button>
                            </form>
                        </div>
                    </c:forEach>
                    <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#createListModal">Create list</button>
                </div>
                <!-- products searchbar -->
                <div class ="col-sm">
                    <input type="text" id="searchBar" onkeyup="searchProducts()" placeholder="Search for products">
                    <div id="searchResult">
                    </div>
                    <script>
                        function searchProducts() {
                            let text = document.getElementById("searchBar").value;
                            var xmlHttp = new XMLHttpRequest();
                            xmlHttp.onreadystatechange = function () {
                                if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
                                    let obj = JSON.parse(xmlHttp.responseText);
                                    console.log(JSON.stringify(obj));
                                    let html = "<ul class='list-unstyled'>";
                                    for (i in obj.result) {
                                        html += "<li class='media'><img class='mr-3' src='https://via.placeholder.com/64'>";
                                        html += "<div class='media-body'><h5 class='mt-0 mb-1'>" + obj.result[i].name + "</h5>";
                                        html += obj.result[i].description;
                                        html += "</div></li>";
                                    }
                                    html += "</ul>"
                                    document.getElementById("searchResult").innerHTML = html;
                                }
                            }
                            xmlHttp.open("GET", "<%=contextPath%>searchProduct?text=" + text, true); // true for asynchronous 
                            xmlHttp.send(null);
                        }
                    </script>
                </div>
            </div>
        </div>

        <!-- // MODAL WINDOWS // -->
        <div class="modal" id="editListModal">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 class="modal-title" id="editListModalTitle">Edit</h4>
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                    </div>
                    <div class="modal-body">
                        <form action="shopping.lists.handler" method="POST">
                            <input type="hidden" name="name" id="editModalListName" required>
                            <input type="hidden" name="listID" id="editModalListID" required>
                            <input type="hidden" name="action" value="edit">
                            <div class="form-group">
                                <label for="editDescriptionInput">Description</label>
                                <input type="text" class="form-control" name="description" id='editDescriptionInput' required>
                            </div>
                            <div class="form-group">  
                                <label for="editCategorySelect">Category</label>
                                <select name="category" class="form-control" id="editCategorySelect" required>
                                    <c:forEach var='cat' items='${categories}'>
                                        <option value='${cat.name}'>${cat.name}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="modal-footer">
                                <button type='submit' class='btn btn-primary'>Edit</button>
                                <button type="button" class="btn btn-danger" data-dismiss="modal">Close</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <div class="modal" id="createListModal">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 class="modal-title">Create list</h4>
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                    </div>
                    <div class="modal-body">
                        <form action="shopping.lists.handler" method="POST">
                            <input type="hidden" name="action" value="create">
                            <div class="form-group">
                                <label for="nameInput">Name</label>
                                <input type="text" class="form-control" name="name" id='nameInput' placeholder="enter list name" required>
                            </div>
                            <div class="form-group">
                                <label for="descriptionInput">Description</label>
                                <input type="text" class="form-control" name="description" id='descriptionInput' placeholder="enter list description" required>
                            </div>
                            <div class="form-group">
                                <label for="categoryInput">Category: ${list.category}</label>
                                <select name="category" id="categoryInput" class="form-control" required>
                                    <c:forEach var='cat' items='${categories}'>
                                        <option value='${cat.name}'>${cat.name}</option>
                                    </c:forEach>
                                </select>   
                            </div>
                            <div class="modal-footer">
                                <button type='submit' class='btn btn-primary'>Create</button>
                                <button type="button" class="btn btn-danger" data-dismiss="modal">Close</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>