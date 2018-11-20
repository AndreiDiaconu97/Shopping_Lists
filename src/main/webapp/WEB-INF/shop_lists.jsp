<%-- 
    Document   : shoppinglists
    Created on : 14-apr-2018, 15.16.06
    Author     : Stefano Chirico &lt;chirico dot stefano at parcoprogetti dot com&gt;
--%>

<%@page import="db.daos.ProductDAO"%>
<%@page import="java.util.ArrayList"%>
<%@page import="db.entities.Product"%>
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
    private ProductDAO productDao;

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

    try {
        List<List_reg> shoppingLists = reg_userDao.getOwningShopLists(reg_user);
        List<List_category> categories = list_catDao.getAll();
        List<Product> products;
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Lab 08: Shopping lists shared with<%=reg_user.getFirstname() + " " + reg_user.getLastname()%></title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <!-- Latest compiled and minified CSS -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" crossorigin="anonymous">
        <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.0.8/css/all.css" crossorigin="anonymous">
        <link rel="stylesheet" href="../css/floating-labels.css">
        <link rel="stylesheet" href="../css/forms.css">
    </head>
    <body>
        <div class="container-fluid">
            <div class="card border-primary">
                <div class="card-header bg-primary text-white">
                    <h5 class="card-title float-left">Shopping Lists</h5><span><a href="<%=contextPath%>restricted/export2PDF?id=<%=reg_user.getId()%>" class="far fa-file-pdf fa-2x text-light float-right" aria-hidden="true"></a></span><button type="button" class="btn btn-outline-light bg-light text-primary btn-sm float-right" data-toggle="modal" data-target="#editDialog"><i class="fas fa-plus" aria-hidden="true"></i></button>
                </div>
                <div class="card-body">
                    The following table lists all the shopping-lists shared with &quot;<%=reg_user.getFirstname() + " " + reg_user.getLastname()%>&quot;.<br>
                </div>
                <!-- Shopping Lists cards -->
                <div id="accordion">
                    <%
                        if (shoppingLists.isEmpty()) {
                    %>
                    <div class="card">
                        <div class="card-body">
                            This collection is empty.
                        </div>
                    </div>
                    <%
                    } else {
                        int index = 1;
                        for (List_reg shoppingList : shoppingLists) {
                    %>
                    <div class="card">
                        <div class="card-header" id="heading<%=index%>">
                            <h5 class="mb-0">
                                <button class="btn btn-link" data-toggle="collapse" data-target="#collapse<%=index%>" aria-expanded="true" aria-controls="collapse<%=index%>">
                                    <%=shoppingList.getName()%>
                                </button>
                                <div class="float-right"><a href="<%=contextPath%>restricted/edit.shopping.list.html?id=<%=shoppingList.getId()%>" class="fas fa-pen-square" title="edit &quot;<%=shoppingList.getName()%>&quot; shopping list" data-toggle="modal" data-target="#editDialog" data-shopping-list-id="<%=shoppingList.getId()%>" data-shopping-list-name="<%=shoppingList.getName()%>" data-shopping-list-description="<%=shoppingList.getDescription()%>"></a></div>
                            </h5>
                        </div>
                        <div id="collapse<%=index%>" class="collapse<%=(index == 1 ? " show" : "")%>" aria-labelledby="heading<%=(index++)%>" data-parent="#accordion">
                            <div class="card-body">
                                <%=shoppingList.getDescription()%>                                
                            <%                                 
                                products = list_regDao.getProducts(shoppingList);
                                if (products == null) {                            
                            %>                 
                                <div class="card">
                                    <div class="card-body">
                                        There are no products in this list.
                                    </div>
                                </div>            
                            <%    
                                }else{
                                    for(Product product : products){
                            %>
                                        <div class="card">
                                            <div class="card-body">
                                                <%=product.getName()%>
                                            </div>
                                        </div>                          
                            <%
                                    }
                                }
                            %>    
                                <form action="shopping.lists.handler" method="POST">
                                    <div class="form-label-group">
                                        <input type="text" name="object_name"><br>
                                        <input type="hidden" name="add" value="add"><br>
                                        <input type="hidden" name="list_id" value="<%=shoppingList.getId()%>"><br>                                     
                                        <button type="add" class="btn btn-primary" id="editDialogSubmit">Add</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                    <%
                            }
                        }
                    %>
                </div>
            </div>
        </div>
        <!-- create/edit shopping list modal dialog (#editDialog) -->
        <form action="shopping.lists.handler" method="POST">
            <div class="modal fade" id="editDialog" tabindex="-1" role="dialog" aria-labelledby="titleLabel">
                <div class="modal-dialog modal-dialog-centered" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h3 class="modal-title" id="titleLabel">Create new/Edit Shopping List</h3>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true"><i class="fas fa-window-close red-window-close"></i></span></button>
                        </div>
                        <div class="modal-body">
                            <input type="hidden" name="idUser" value="<%=reg_user.getId()%>">
                            <input type="hidden" name="idShoppingList" id="idShoppingList">
                            <div class="form-label-group">
                                <input type="text" name="name" id="name" class="form-control" placeholder="Name" required autofocus>
                                <label for="name">Name</label>
                            </div>
                            <div class="form-label-group">
                                <input type="text" name="description" id="description" class="form-control" placeholder="Description" required>
                                <label for="description">Description</label>
                            </div>
                            <select name="category">
                                <% for (List_category cat : categories) {%>
                                <option value="<%=cat.getName()%>"><%=cat.getName()%></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="modal-footer">
                            <input type="hidden" name="create" value="create"><br> 
                            <button type="submit" class="btn btn-primary" id="editDialogSubmit">Create</button>
                            <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                        </div>
                    </div>
                </div>
            </div>
        </form>
        <!-- Latest compiled and minified JavaScript -->
        <script src="https://code.jquery.com/jquery-3.2.1.min.js" crossorigin="anonymous"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.18.1/moment.min.js" crossorigin="anonymous"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" crossorigin="anonymous"></script>
        <script type="text/javascript">
            $(function () {
                $("#editDialog").on("show.bs.modal", function (e) {
                    var target = $(e.relatedTarget);
                    var shoppingListId = target.data("shopping-list-id");
                    if (shoppingListId !== undefined) {
                        var shoppingListName = target.data("shopping-list-name");
                        var shoppingListDescription = target.data("shopping-list-description");

                        $("#titleLabel").html("Edit Shopping List (" + shoppingListId + ")");
                        $("#editDialogSubmit").html("Update");
                        $("#idShoppingList").val(shoppingListId);
                        $("#name").val(shoppingListName);
                        $("#description").val(shoppingListDescription);
                    } else {
                        $("#titleLabel").html("Create new Shopping List");
                        $("#editDialogSubmit").html("Create");
                    }
                });
            });
        </script>

    </body>
</html>
<%
} catch (Exception ex) {
    System.err.println(ex);
%>
<jsp:forward page="/error.html">
    <jsp:param name="error" value="shop_list"/>
</jsp:forward>
<%
    }
%>