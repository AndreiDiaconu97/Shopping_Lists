<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // status = wrongpsw, needtoverify, needtoregister, dberror, error
    String status = request.getParameter("status");
    if(status==null){
        status="normal";
    }
    Boolean error = status.contains("error");
    pageContext.setAttribute("status", status);
    pageContext.setAttribute("error", error);
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Lab 08: Authentication Area</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <!-- Latest compiled and minified CSS -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" crossorigin="anonymous">
        <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.0.8/css/all.css" crossorigin="anonymous">
        <!-- Custom styles for this template -->
        <link href="css/floating-labels.css" rel="stylesheet">
        <link rel="stylesheet" href="css/floating-labels.css" type="text/css"/>
        <link rel="stylesheet" href="css/signin.css" type="text/css">


    </head>
    <body>
        <c:if test="${status=='validated'}"><div class="alert-success" role="alert">Registrato! login now<br></div></c:if>
        <form class="form-signin" action="auth" method="POST">
            <div class="text-center mb-4">
                <img class="mb-4" src="images/unitn_logo_1024.png" alt="UNITN Logo" width="128" height="128">
                <h3 class="h3 mb-3 font-weight-normal">Authentication Area</h3>
                <p>You must authenticate to access, view, modify and share your Shopping Lists</p>
            </div>
            <div class="form-label-group">
                <input type="email" id="email" name="email" class="form-control" placeholder="email" required autofocus>
                <label for="email">Email</label>
            </div>
            <div class="form-label-group">
                <input type="password" id="password" name="password" class="form-control" placeholder="Password" required>
                <label for="password">Password</label>
                <c:if test="${status=='wrongpsw'}"><div class="alert-danger" role="alert">Password sbagliata<br></div></c:if>
            </div>
            <div class="checkbox mb-3">
                <label>
                    <input type="checkbox" name="rememberMe" value="true"> Remember me
                </label>
            </div>
            <input type="hidden" name="login" value="true"><br>
            <button class="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>
        </form>
    </body>
</html>
