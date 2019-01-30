<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix = "fn" uri = "http://java.sun.com/jsp/jstl/functions" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!-- alreadyregistered, needtoverify, error, mailerror, dberror, success -->
<c:if test="${fn:contains(param.status, 'error')}">
    <c:url value = "error.html" var = "errorURL">
        <c:param name = "error" value = "${param.status}"/>
    </c:url>
    <c:redirect url="${errorURL}"/>
</c:if>

<!DOCTYPE html>
<html>

    <head>
        <title>User registration</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">     
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" crossorigin="anonymous">
    </head>

    <body>
        <div class="jumbotron text-center mb-4">
            <img class="mb-4" src="images/registration" width="128" height="128">
            <h3 class="h3 mb-3 font-weight-normal">Registration Area</h3>
            <p>Please compile the following registration form</p>
        </div>
        <div class="container">
            <div class="col-12 col-lg-6 mx-auto">
                <form action="auth" method="POST">
                    <div class="form-group">
                        <label for="emailInput">Email</label>
                        <input type="email" class="form-control" name="email" id='emailInput' placeholder="enter email" required>
                    </div>
                    <div class="form-group">
                        <label for="firstnameInput">First name</label>
                        <input type="text" class="form-control" name="firstname" id='firstnameInput' placeholder="enter your first name" required>
                    </div>
                    <div class="form-group">
                        <label for="lastnameInput">Last name</label>
                        <input type="text" class="form-control" name="lastname" id='lastnameInput' placeholder="enter your last name" required>
                    </div>
                    <div class="form-group">
                        <label for="passwordInput">Password</label>
                        <input type="password" class="form-control" name="password" id='passwordInput' placeholder="enter yor password" required>
                    </div>
                    <input type="checkbox" required>I agree..<br>
                    <input class="btn btn-primary mt-2" type="submit" name="action" value="register">
                </form>
                <div class="row justify-content-between">
                    <button class="btn btn-secondary btn-sm ml-auto mt-2" type="submit">
                        <a href="login.html" class="my-auto" style="color: white; text-decoration: none">
                            Go to login
                        </a>
                    </button>
                </div>
                <c:choose>
                    <c:when test="${param.status=='success'}">
                        Registrato con successo!!Vai a <a href="/Shopping/login.html">login</a><br>
                    </c:when>
                    <c:when test= "${param.status=='alreadyregistered'}">
                        Già registrato! Vai a <a href="/Shopping/login.html">login</a><br>
                    </c:when>
                    <c:when test="${param.status=='needtoverify'}">
                        Devi verificare il tuo account. Controlla la tua mail<br>
                    </c:when>
                </c:choose>
            </div>
        </div>

        <footer class="footer font-small blue mt-4">
            <div class="p-3 bg-dark text-white">
                Follow us on Github: <a href="https://github.com/AndreiDiaconu97/Shopping_Lists"> Shopping_Lists</a>
            </div>
        </footer>
    </body>
</html>