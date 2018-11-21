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
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"></script>
    </head>
    <body>
        <div class="jumbotron">
            Created by me:<br>
            <c:forEach var='list' items='${myLists}'>
                <button class='btn' data-toggle='collapse' data-target='#collapse${list.getId()}'>${list.getName()} (Id: ${list.getId()})</button>
                <br>
                <div id='collapse${list.getId()}' class='collapse'>
                    Description:<br>${list.getDescription()}<br>
                    Category: ${list.getCategory()}<br>
                    Products<ul>
                        <c:forEach var='product' items='${list_regDao.getProducts(list)}'>
                            <li>${product.getName()}</li>
                        </c:forEach>
                    </ul>
                    <button class="btn" data-toggle='modal' data-target='#editListModal' onclick='
                        document.getElementById("editModalListName").value = "${list.getName()}";
                        document.getElementById("editListModalTitle").innerHTML = "Edit ${list.getName()}";
                        document.getElementById("editDescriptionInput").value = "${list.getDescription()}";
                        document.getElementById("editModalListID").value = ${list.getId()};
                        document.getElementById("editCategorySelect").selectedIndex = "${categories.indexOf(list_catDao.getByPrimaryKey(list.getCategory()))}";
                    '>edit</button>
                    <form action="shopping.lists.handler" method="POST">
                        <input type="hidden" name="list_id" value='${list.getId()}'>
                        <input type="hidden" name="delete" value="delete">
                        <button type="submit" class='btn btn-primary'>Delete</button>
                    </form>
                </div>
            </c:forEach>

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
                                Description:<br><input type="text" name="description" id='editDescriptionInput' required><br>
                                <select name="category" id="editCategorySelect" required>
                                    <c:forEach var='cat' items='${categories}'>
                                        <option value='${cat.getName()}'>${cat.getName()}</option>
                                    </c:forEach>
                                </select>
                                <input type="hidden" name="listID" id="editModalListID" required>
                                <input type="hidden" name="edit" value="edit">
                                <button type='submit' class='btn btn-primary'>Edit</button>
                            </form>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-danger" data-dismiss="modal">Close</button>
                        </div>
                    </div>
                </div>
            </div>



            <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#createListModal">Create list</button>
            <div class="modal" id="createListModal">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h4 class="modal-title">Modal Heading</h4>
                            <button type="button" class="close" data-dismiss="modal">&times;</button>
                        </div>
                        <div class="modal-body">
                            <form action="shopping.lists.handler" method="POST">
                                Name:<br><input type="text" name="name" required><br>
                                Description:<br><input type="text" name="description" required><br>
                                Category: ${list.getCategory()}<br>
                                <select name="category" required>
                                    <c:forEach var='cat' items='${categories}'>
                                        <option value='${cat.getName()}'>${cat.getName()}</option>
                                    </c:forEach>
                                </select>
                                <input type="hidden" name="create" value="create">
                                <button type='submit' class='btn btn-primary'>Create</button>
                            </form>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-danger" data-dismiss="modal">Close</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="jumbotron">
            Shared with me:<br>
            <c:forEach var='list' items='${sharedLists}'>
                <button class='btn' data-toggle='collapse' data-target='#collapse${list.getId()}'>${list.getName()} (Id: ${list.getId()})</button>
                <div id='collapse${list.getId()}' class='collapse'>
                    Description:<br>${list.getDescription()}<br>
                </div>
            </c:forEach>
        </div>
    </body>
</html>