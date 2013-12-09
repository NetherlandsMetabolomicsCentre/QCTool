<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>QC-Tool</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">

    <!-- CSS -->
    <link rel="stylesheet" href="${resource(dir: 'css', file: 'bootstrap.min.css')}">
    <style type="text/css">

        /* Sticky footer styles
       -------------------------------------------------- */

    html,
    body {
        height: 100%;
        /* The html and body elements cannot have any padding or margin. */
    }

    .container {
        width: 98%;
    }

        /* Wrapper for page content to push down footer */
    #wrap {
        min-height: 100%;
        height: auto !important;
        height: 100%;
        /* Negative indent footer by it's height */
        margin: 0 auto -60px;
    }

        /* Set the fixed height of the footer here */
    #push,
    #footer {
        height: 60px;
    }

    #footer {
        background-color: #f5f5f5;
    }

        /* Lastly, apply responsive CSS fixes as necessary */
    @media (max-width: 767px) {
        #footer {
            margin-left: -20px;
            margin-right: -20px;
            padding-left: 20px;
            padding-right: 20px;
        }
    }

        /* Custom page CSS
       -------------------------------------------------- */
        /* Not required for template or sticky footer method. */

    #wrap > .container {
        padding-top: 60px;
    }

    .container .credit {
        margin: 20px 0;
    }

    code {
        font-size: 80%;
    }

    </style>

    <!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
      <script src="../assets/js/html5shiv.js"></script>
    <![endif]-->

    <g:javascript library="jquery"/>
    <g:layoutHead/>
    <r:layoutResources/>
</head>

<body>

    <div class="container">
        <g:layoutBody/>
    </div>

<g:javascript library="jquery"/>
<script src="${resource(dir: 'js/', file: 'bootstrap.min.js')}"></script>
<g:javascript library="application"/>
<r:layoutResources/>

</body>
</html>
