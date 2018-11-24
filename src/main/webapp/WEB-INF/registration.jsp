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
    </head>

    <body>
        <div>TODO write content</div>
        <form action="auth" method="POST">
            Email:<br>
            <input type="email" name="email" required><br>
            First name:<br>
            <input type="text" name="firstname" required><br>
            Last name:<br>
            <input type="text" name="lastname" required><br>
            Password:<br>
            <input type="password" name="password" required><br>
            <input type="checkbox" required>I agree..<br>
            <input type="submit" name="register" value="Register"><br>
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
    </body>

</html>