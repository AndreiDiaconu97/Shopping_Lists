<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix = "fn" uri = "http://java.sun.com/jsp/jstl/functions" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!-- param.status = wrongpsw, needtoverify, needtoregister, dberror, error -->
<c:if test="${fn:contains(param.status, 'error')}">
    <c:url value = "error.html" var = "errorURL">
        <c:param name = "error" value = "${param.status}"/>
    </c:url>
    <c:redirect url="${errorURL}"/>
</c:if>

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
        <div class="container mt-2">
            <form class="form-signin" action="auth" method="POST">
                <div class="text-center mb-4">
                    <img class="mb-4" src="images/login" alt="UNITN Logo" width="128" height="128">
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
                    <c:if test="${param.status=='wrongpsw'}">
                        <div class="alert-danger" role="alert">
                            Password sbagliata<br>
                        </div>
                    </c:if>
                </div>
                <div class="checkbox mb-3">
                    <label>
                        <input type="checkbox" name="rememberMe" value="true"> Remember me
                    </label>
                </div>
                <input type="hidden" name="action" value="login"><br>
                <button class="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>
            </form>
            <c:choose>
                <c:when test="${param.status=='validated'}">
                    <div class="alert-success" role="alert">
                        Registrato! login now.
                    </div>
                </c:when>
                <c:when test="${param.status=='needtoverify'}">
                    <div class="alert-danger" role="alert">
                        Need to verify, check your Email.
                    </div>
                </c:when>
                <c:when test="${param.status=='needtoregister'}">
                    <div class="alert-danger" role="alert">
                        Email not found, register first.
                    </div>
                </c:when>
                <c:when test="${param.status=='notadmin'}">
                    <div class="alert-danger" role="alert">
                        To access admin pages, please login with an administrator account.
                    </div>
                </c:when>
            </c:choose>
        </div>
    </body>
</html>
