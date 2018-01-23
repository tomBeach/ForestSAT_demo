$(document).ready(function() {
    console.log("== jQuery loaded ==");

    var sessionTitleDisplay = $('#titleDetail');
    var authorNamesDisplay = $('#authorDetail');
    var authorHash = {
        1: ["First Author One", "First Author Two", "First Author Three"],
        2: ["Second Author One", "Second Author Two", "Second Author Three"],
        3: ["Third Author One", "Third Author Two", "Third Author Three"]
    }

    function activateHoverInfo(e) {
        console.log("== activateHoverInfo ==");
        var sessionItems = $('.session').on('mouseenter', showSessionDetail);
        var sessionItems = $('.session').on('mouseleave', showSessionDetail);
    }

    function showSessionDetail(e) {
        console.log("== showSessionDetail ==");
        var sessionTitle = $('#' + e.currentTarget.id).text();
        if ($(sessionTitleDisplay).html() == "") {
            var nextAuthors;
            var authorHtml = "";
            var authorsList = authorHash[e.currentTarget.id];
            for (var i = 0; i < authorsList.length; i++) {
                nextAuthor = authorsList[i];
                authorHtml += "<p class='authorDisplay'>";
                authorHtml += nextAuthor;
                authorHtml += "</p>";
            }
            $(sessionTitleDisplay).html("<p class='titleDisplay'>" + sessionTitle + "</p>");
            $(authorNamesDisplay).html(authorHtml);
        } else {
            $(sessionTitleDisplay).html("");
            $(authorNamesDisplay).html("");
        }
    };
    activateHoverInfo();
});
