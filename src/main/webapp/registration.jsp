<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String status = request.getParameter("status");
    //if(status==null){
    //  status="normal";
    //return;
    //}
    Boolean error = status.contains("error");
    pageContext.setAttribute("status", status);
    pageContext.setAttribute("error", error);
%>
<!DOCTYPE html>
<html>

    <head>
        <title>TODO supply a title</title>
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
        <c:if test="${status=='success'}">Registrato con successo!!Vai a <a href="/Shopping/login.html">login</a><br></c:if>
        <c:if test= '${status=="alreadyregistered"}'>Già registrato! Vai a <a href="/Shopping/login.html">login</a><br></c:if>
        <c:if test= '${status=="needtoverify"}'>Devi verificare il tuo account. Controlla la tua mail<br></c:if>
        <c:if test="${error}">Errore!!(specificare?)<br></c:if>
    </body>

</html>