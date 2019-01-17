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
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    </head>
    <body>
        <!-- navbar -->
        <nav class="navbar navbar-expand-md navbar-dark bg-dark sticky-top shadow">
            <div class="container-fluid">
                <!-- Title -->
                <div class="navbar-header">
                    <a class="navbar-brand " href=""><h4>Shopping lists</h4></a>
                </div>

                <ul class="nav navbar-nav">
                    <li class="nav" style="display: inline-block">
                        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                            <span class="navbar-toggler-icon"></span>
                        </button>
                        <div class="collapse navbar-collapse" id="navbarSupportedContent">
                            <ul class="nav navbar-nav">
                                <li class="dropdown pull-right">
                                    <a class="nav-link" href="#">Sign in <i class="fa fa-sign-in" style="font-size:20px;"></i></a>
                                </li>
                                <li class="dropdown pull-right">
                                    <a class="nav-link" href="#">Log in <i class="fa fa-user" style="font-size:20px;"></i></a>
                                </li>
                            </ul>
                        </div> 
                    </li>
                </ul>
            </div>
        </nav>

        <!-- name and logo -->
        <div class="container-fluid pt-2 pb-3 mb-2 shadow">
            <div class="row justify-content-center">
                <div class="col-8 col-sm-2 px-0 mx-2">
                    <img class="img-fluid rounded-circle shadow" alt="Responsive image" src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Logo-Free.jpg">
                </div>
                <div class="text-center my-auto mx-2" style="text-shadow: 2px 2px 8px #bbbbbb;">
                    <h2>Shopping list name</h2>
                </div>
                <h4><small><span class="badge badge-pill badge-secondary shadow">Category</span></small></h4>
            </div>
        </div>

        <!-- owner + chat + participants -->
        <div class="container-fluid mb-2 bg-dark text-white">
            <div class="row justify-content-between py-2 mx-auto">
                <p class="font-weight-light mr-2 my-auto" style="color: grey">
                    Created by <span style="color: whitesmoke; font-size: 15pt">Cristos</span>  
                </p>
                <button type="button" class="btn btn-dark btn-sm mx-1 ml-auto" href="#chatModal" data-toggle="modal">
                    <i class="fa fa-comments" style="font-size:30px; color: graytext"></i>
                </button>
                <button type="button" class="btn btn-dark btn-sm mx-1" href="#participantsModal" data-toggle="modal">
                    <i class="fa fa-users" style="font-size:30px; color: graytext"></i>
                </button>
            </div>
        </div>

        <!-- description spoiler -->
        <div class="container-fluid mb-4">
            <div class="panel panel-success autocollapse">
                <div class="panel-heading clickable">
                    <div class="row mx-auto">
                        <i class="fa fa-chevron-circle-down mr-2 my-auto" style="font-size:20px;"></i>
                        <div class="text-left my-auto">Description</div>
                    </div>
                    <hr>
                </div>
                <div class="panel-body">
                    <div class="text-justify mx-4">
                        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus eget ante sed nisl semper bibendum vel id quam. Maecenas aliquam urna suscipit, posuere leo eu, efficitur arcu. Phasellus convallis vel odio vitae viverra. Quisque a ipsum sem. Duis interdum finibus iaculis. Nam metus eros, accumsan suscipit erat malesuada, dictum ullamcorper purus. Aliquam viverra imperdiet hendrerit. Maecenas condimentum massa non lectus elementum vestibulum. Nunc sodales nisl ullamcorper diam porta varius. Nam viverra feugiat malesuada. Vivamus mollis lectus quis metus egestas, eu molestie erat rutrum. Aliquam congue nisi sit amet mauris rhoncus, sed finibus nisi vulputate. Etiam at rhoncus justo.
                    </div>
                </div>
            </div>
        </div>

        <!-- products -->
        <div class="card mb-3 shadow border-0">
            <div class="card-header">
                <div class="row my-auto mx-1">
                    <h4 class="my-auto pb-2">Products <small><span class="badge badge-secondary shadow">3/7</span></small></h4>
                    <div class="row ml-auto">
                        <div class="input-group">
                            <input class="form-control" type="search" placeholder="Search products in list..." aria-label="Search">
                            <button class="btn btn-outline-success" type="submit">
                                <i class="fa fa-search mr-auto" style="font-size:20x;"></i>
                            </button>   
                            <button type="button" class="btn btn-primary ml-2 my-auto shadow rounded-circle" href="#addProductModal" data-toggle="modal">          
                                <i class="fa fa-plus mr-auto" style="font-size:20x;"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="container-fluid">
            <c:forEach var = "i" begin="0" end="20">
                <div class="card shadow-sm mb-2">
                    <div class="card-body">
                        <div class="row">
                            <img class="img-fluid img-thumbnail rounded mx-2" style="min-width: 50px; min-height: 100%; max-width: 100%; max-height: 60px"  alt="Responsive image" src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Logo-Free.jpg">
                            <div class="text-left my-auto">
                                product ${i}
                            </div>
                            <div class="row ml-auto my-auto mr-1 pt-2">
                                <div class="input-group">
                                    <button type="button" id="leftBtn${i}" class="btn btn-secondary btn-sm shadow-sm" onclick="changeValue(this.id, '-')">
                                        <i class="fa fa-chevron-left mr-auto"></i>
                                    </button>
                                    <input type="number" id="buyProd${i}" class="form-control rounded shadow-sm" style="appearance: none; margin: 0"  name="quantity" min="0" max="5" placeholder="0" oninput="handleChange(this)"><br>
                                    <div class="input-group-append">
                                        <span class="input-group-text" id="basic-addon2">5</span>
                                    </div>
                                    <button type="button" id="rightBtn${i}" class="btn btn-secondary btn-sm shadow-sm" onclick="changeValue(this.id, '+')">
                                        <i class="fa fa-chevron-right mr-auto"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
            <c:forEach var = "i" begin="0" end="20">
                <div class="card shadow-sm mb-2" style="background-color: whitesmoke">
                    <div class="card-body">
                        <div class="row">
                            <img class="img-fluid img-thumbnail rounded mx-2" style="min-width: 50px; min-height: 100%; max-width: 100%; max-height: 60px"  alt="Responsive image" src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Logo-Free.jpg">
                            <div class="text-left my-auto">
                                product ${i}
                            </div>
                            <div class="row ml-auto my-auto mr-4 pt-2">
                                <i class="fa fa-minus mr-auto"></i>
                            </div>
                        </div
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
    <!-- MODALS -->

    <!-- chat -->
    <div class="modal modal-fluid" id="chatModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header shadow">
                    <i class="fa fa-comments mr-auto" style="font-size:30px;"></i>
                    <h5 class="modal-title" id="exampleModalLongTitle">Group chat</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body" style="height:72vh; overflow-y:scroll; width: 100%" >
                    <c:forEach var="i" begin="0" end="15">
                        <div class="row mb-2 ml-0">
                            <div class="col-3 col-md-2">
                                <div class="row">
                                    <img class="img-thumbnail shadow-sm" style="width: 100px; height: 100%; min-width: 50px; min-height: 100%" alt="Responsive image" src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Logo-Free.jpg">
                                </div>
                                <div class="row">
                                    User${i} can be a very long name too  
                                </div>
                            </div>
                            <div class="col">
                                message${i} an be a very lon one sads asd saas dasd asd sasd asd wda awwad aw awaw dw aw awwad waddaw wad
                            </div>
                        </div>
                        <hr>
                    </c:forEach>
                </div>
                <div class="modal-footer form-horizontal">
                    <input class="form-control mr-2" type="text" style="width: 92%" placeholder="write a message..." aria-label="wrile a message...">
                    <button type="submit" class="btn btn-secondary"><i class="fa fa-arrow-circle-right my-auto" style="font-size:23px;"></i></button>
                </div>
            </div>
        </div>
    </div>

    <!-- participants -->
    <div class="modal modal-fluid" id="participantsModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header shadow">
                    <i class="fa fa-users mr-auto" style="font-size:30px;"></i>
                    <h5 class="modal-title" id="exampleModalLongTitle">Participants</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body" style="height:72vh; overflow-y:scroll; width: 100%" >
                    <c:forEach var="i" begin="0" end="15">
                        <div class="row mb-2 px-auto ml-0">
                            <img class="img-thumbnail shadow-sm mr-2" style="width: 70px; height: 100%; min-width: 50px; min-height: 100%" alt="Responsive image" src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Logo-Free.jpg">
                            <p class="mr-2 my-auto" style="color: grey">
                                User${i} can be a very long name too  
                            </p>
                            <div class="row ml-auto mx-2 my-2">
                                <div class="input-group my-auto">
                                    <select class="custom-select" id="inputGroupSelect02">
                                        <option value="1">buy only</option>
                                        <option value="2" selected>can edit</option>
                                        <option value="3">full control</option>
                                    </select>
                                    <div class="input-group-append">
                                        <label class="input-group-text" for="inputGroupSelect02">
                                            <i class="fa fa-wrench" style="font-size:25px"></i>
                                        </label>
                                    </div>
                                </div>
                            </div>
                            <button type="button" class="btn btn-danger my-auto mr-2 shadow-sm rounded" style="" data-toggle="button" aria-pressed="false">
                                <i class="fa fa-user-times" style="font-size:25px"></i>
                            </button>
                        </div>
                        <hr>
                    </c:forEach>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" data-dismiss="modal">Confirm changes</button> 
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </div>

    <!-- add product -->
    <div class="modal modal-fluid" id="addProductModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-dialog-centered modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header shadow">
                    <i class="fa fa-cart-plus mr-auto" style="font-size:30px;"></i>
                    <h5 class="modal-title" id="exampleModalLongTitle">Add product to list</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body" style="height:72vh; overflow-y:scroll; width: 100%" >
                    <c:forEach var="i" begin="0" end="15">
                        <div class="container-fluid rounded shadow border mb-2" style="background-color: whitesmoke">
                            <div class="row my-2 ml-0">
                                <img class="img-thumbnail mx-auto my-auto" style="width: 100px; height: 100%; min-width: 50px; min-height: 100%" alt="Responsive image" src="https://upload.wikimedia.org/wikipedia/commons/4/4c/Logo-Free.jpg">
                                <div class="col my-auto">
                                    <div class="text-left">
                                        Product${i} can be a very long name too rterg ge gr egg reg er eer er rer ege er erer er
                                    </div>  
                                </div>
                            </div>
                            <div class="row mx-0 justify-content-between">
                                <div class="row mx-0 my-auto">
                                    <div class="input-group mb-3 my-auto">
                                        <c:forEach var="i" begin="0" end="3">
                                            <i class="fa fa-star" style="font-size:21px;"></i>
                                        </c:forEach>
                                        <i class="fa fa-star-o" style="font-size:21px;"></i>
                                    </div>
                                </div>
                                <div class="badge badge-pill badge-secondary shadow my-auto">Category</div>
                                <div class="text-left">31212242 ratings</div>  
                            </div>
                            <hr>
                            <div class="panel panel-success autocollapse">
                                <div class="panel-heading clickable">
                                    <div class="row mx-auto">
                                        <p>Description</p>
                                        <i class="fa fa-chevron-circle-down ml-2" style="font-size:25px;"></i>
                                        <div class="text ml-auto mr-2" style="color: grey">created by</div>
                                        <div class="text" style="font-size: 18px">Author</div>
                                    </div>
                                </div>
                                <div class="panel-body">
                                    <div class="text-justify mx-4 mb-4">
                                        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus eget ante sed nisl semper bibendum vel id quam. Maecenas aliquam urna suscipit, posuere leo eu, efficitur arcu. Phasellus convallis vel odio vitae viverra. Quisque a ipsum sem. Duis interdum finibus iaculis. Nam metus eros, accumsan suscipit erat malesuada, dictum ullamcorper purus. Aliquam viverra imperdiet hendrerit. Maecenas condimentum massa non lectus elementum vestibulum. Nunc sodales nisl ullamcorper diam porta varius. Nam viverra feugiat malesuada. Vivamus mollis lectus quis metus egestas, eu molestie erat rutrum. Aliquam congue nisi sit amet mauris rhoncus, sed finibus nisi vulputate. Etiam at rhoncus justo.
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
                <div class="modal-footer form-horizontal">
                    <div class="row ml-auto mx-2 my-2">
                        <div class="input-group my-auto">
                            <select class="custom-select" id="inputGroupSelect02">
                                <option value="1">buy only</option>
                                <option value="2" selected>TODO</option>
                                <option value="3">full control</option>
                            </select>
                        </div>
                    </div>
                    <input class="form-control mr-2" type="text" style="width: 92%" placeholder="insert product name..." aria-label="wrile a message...">
                    <button type="submit" class="btn btn-secondary">
                        <i class="fa fa-search my-auto" style="font-size:23px;"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <footer class="page-footer font-small blue pt-3">
        <hr>
        <div class="p-3 mb-2 bg-dark text-white">
            Follow us on Github: <a href="https://github.com/AndreiDiaconu97/Shopping_Lists"> Shopping_Lists</a>
        </div>
    </footer>

    <script>
        // spoiler setup 
        $(document).on('click', '.panel div.clickable', function (e) {
            var $this = $(this); //Heading
            var $panel = $this.parent('.panel');
            var $panel_body = $panel.children('.panel-body');
            var $display = $panel_body.css('display');

            if ($display === 'block') {
                $panel_body.slideUp();
            } else if ($display === 'none') {
                $panel_body.slideDown();
            }
        });
        $(document).ready(function (e) {
            var $classy = '.panel.autocollapse';

            var $found = $($classy);
            $found.find('.panel-body').hide();
            $found.removeClass($classy);
        });

        // in/decrement buttons
        function changeValue(buttonID, operator) {
            var textID = buttonID.match(/\d+/g);
            var value = parseInt(document.getElementById('buyProd' + textID).value, 10);
            value = isNaN(value) ? 0 : value;

            var maxVal = parseInt(document.getElementById('buyProd' + textID).max, 10);
            var minVal = parseInt(document.getElementById('buyProd' + textID).min, 10);
            switch (operator) {
                case '+':
                    if (value < maxVal) {
                        value++;
                    } else if (value > maxVal) {
                        value = maxVal;
                    }
                    break;
                case '-':
                    if (value > minVal) {
                        value--;
                    } else if (value < maxVal) {
                        value = minVal;
                    }
                    break;
            }
            document.getElementById('buyProd' + textID).value = value;
        }

        // product input range limiter
        function handleChange(input) {
            if (!input.value) {
                return;
            }
            if (input.value < parseInt(input.min)) {
                input.value = input.min;
            }
            if (input.value > parseInt(input.max)) {
                input.value = input.max;
            }
        }
    </script>
</body>
</html>

