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

<%
    String contextPath = getServletContext().getContextPath();
    if (!contextPath.endsWith("/")) {
        contextPath += "/";
    }
    if(session.getAttribute("user")!=null){
        if(!response.isCommitted()){
            response.sendRedirect(contextPath + "restricted/homepage.html");
        }
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <title>Shopping lists</title>
        <noscript>
        <META HTTP-EQUIV="Refresh" CONTENT="0;URL=../error.html?error=nojs">
        </noscript>
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
        <div class="jumbotron text-center mb-4">
            <img class="mb-4" src="images/login" width="128" height="128">
            <h3 class="h3 mb-3 font-weight-normal">Authentication Area</h3>
            <p>You must authenticate to access, view, modify and share your Shopping Lists</p>
        </div>
        <div class="container">
            <div class="col-12 col-lg-6 mx-auto">
                <form class="form-signin" action="auth" method="POST">
                    <div class="md-form mb-3">
                        <i class="fa fa-at prefix grey-text"></i>
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <label class="input-group-text">email</label>
                            </div>  
                            <input type="email" id="email" name="email" class="form-control" placeholder="email" required autofocus>
                        </div>
                    </div>
                    <div class="md-form mb-3">
                        <i class="fa fa-key prefix grey-text"></i>
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <label class="input-group-text">password</label>
                            </div>
                            <input type="password" id="password" name="password" class="form-control" placeholder="Password" required>
                        </div>
                        <c:if test="${param.status=='wrongpsw'}">
                            <div class="alert-danger" role="alert">
                                Password sbagliata<br>
                            </div>
                        </c:if>
                    </div>
                    <button class="btn btn-primary mt-2" type="submit">Log in</button>
                    <input type="hidden" name="action" value="login"><br>
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
        </div>
        <hr>
        <div class="container mt-4 mb-4 mx-auto">
            <div class="row mx-auto mb-2 justify-content-center my-auto">
                <div class="text-left my-auto mr-2">Aren't you registered yet? Subscribe here</div>
                <a href="registration.html" class="btn btn-info ml-2">Sign up</a>
            </div>
            <hr>
            <div class="row mx-auto justify-content-center my-auto mb-2">
                <div class="text-left my-auto mr-2">Or you can just enter as a non registered user</div>
                <a href="anonymous/homepage.html" class="btn btn-success my-auto">
                    <i class="fa fa-shopping-cart" style="font-size:30px"></i>
                    Enter
                </a>
            </div>
        </div>
        <footer class="footer font-small blue">
            <div class="p-3 bg-dark text-white">
                Follow us on Github: <a href="https://github.com/AndreiDiaconu97/Shopping_Lists"> Shopping_Lists</a>
            </div>
        </footer>
    </body>
</html>
