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
        <div class="container">
            <div class="jumbotron">
                <div>TODO write content</div>
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
                    <input type="submit" name="action" value="register"><br>
                </form>
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
    </body>
</html>