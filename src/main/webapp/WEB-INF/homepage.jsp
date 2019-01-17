<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
    <head>
        <title>Shopping lists manager</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" charset="UTF-8">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"></script>
    </head>
    <body>
        <nav class="navbar navbar-expand-md navbar-dark bg-dark sticky-top shadow">
            <a class="navbar-brand" href=""><h4>Shopping lists</h4></a>
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarSupportedContent">
                <button class="btn navbar-button btn-sm mr-2 ml-auto" type="button">Sign in</button>
                <button class="btn navbar-button btn-sm" type="button">Log in</button>
            </div>
        </nav>
        <main role="main">
            <!-- Main jumbotron for a primary marketing message or call to action -->
            <div class="jumbotron">
                <div class="container-fluid">
                    <h1 class="display-3">Hello, world!</h1>
                    <p>This is a template for a simple marketing or informational website. It includes a large callout called a jumbotron and three supporting pieces of content. Use it as a starting point to create something more unique.</p>
                </div>
            </div>
        </div>
        <div class="container-fluid">
            <div class="row ml-auto justify-content-around">
                <div class="col-md-4 mb-3">
                    <div class="dropdown">
                        <button class="btn btn-info dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            Category
                        </button>
                        <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                            <a class="dropdown-item" href="#">Chiodi&viti</a>
                            <a class="dropdown-item active" href="#">SpesaVegan</a>
                            <a class="dropdown-item" href="#">Vinili</a>
                        </div>
                    </div>
                </div>
                <form class="input-group col-md-4">
                    <input class="form-control mr-sm-0" type="search" placeholder="Search list..." aria-label="Search">
                    <button class="btn btn-outline-success mb-3" type="submit">Search</button>
                </form>
            </div>  
        </div>
        <div class="container-fluid">
            <div class="row justify-content-center">
                <!-- shopping lists -->
                <c:forEach begin="0" end="20">
                    <div class="card my-3 mx-4" style="width: 16rem;">
                        <img class="card-img-top" src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Logo-Free.jpg" alt="Card image cap">
                        <div class="card-body">
                            <h5 class="card-text">List name</h5>
                        </div>
                        <div class="card-footer text-muted">
                            Category
                            <span class="badge badge-pill badge-secondary">3/7</span>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>
</main>
<footer class="page-footer font-small blue pt-3">
    <hr>
    <div class="p-3 mb-2 bg-dark text-white">
        Follow us on Github: <a href="https://github.com/AndreiDiaconu97/Shopping_Lists"> Shopping_Lists</a>
    </div>
</footer>
</body>
</html>

