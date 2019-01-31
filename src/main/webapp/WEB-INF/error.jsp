<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    //pageContext.setAttribute("name", "OK");
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Error</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <!-- Latest compiled and minified CSS -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" crossorigin="anonymous">
    </head>
    <body>
        <div class="jumbotron">
            <div class="container">
                <div class="card border-danger">
                    <div class="card-header bg-danger text-white">
                        <h3 class="card-title">Server Error</h3>
                    </div>
                    <div class="card-body">
                        <c:choose>
                            <c:when test='${param.error == "shop_list"}'>Error in retrieving shopping lists</c:when>
                            <c:when test='${param.error == "list_cat"}'>Error in retrieving list categories</c:when>
                            <c:when test='${param.error == "nojs"}'>Please enable javascript and retry</c:when>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
        <!-- Latest compiled and minified JavaScript -->
        <script src="https://code.jquery.com/jquery-3.2.1.min.js" crossorigin="anonymous"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" crossorigin="anonymous"></script>
    </body>
</html>
