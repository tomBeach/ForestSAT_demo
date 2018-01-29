$(document).on('turbolinks:load', function() {
    console.log("== turbolinks:load ==");

    // ======= check pathname =======
    var pathname = window.location.pathname;
    console.log("pathname:", pathname);
    var pathPartsCount = (pathname.split("/").length - 1);
    console.log("pathPartsCount:", pathPartsCount);

    // ======= window conditionals =======
    if (pathname == "/assign_reviewers") {
        activateSubmitReviewers();
    } else if (pathname == "/review_abstracts") {
        activateRevAbsBtns();
    } else if ((pathname == "/select_abstracts") || (pathname == "/filter_by_keyword")) {
        var tooltip = "Click link to see reviewer comments and abstract details."
        var targetElement = "#selabsScrollTable > tbody > tr > td:nth-of-type(1) > a";
        customToolTips(targetElement, tooltip);
        activateSubmitSelection();
    } else if ((pathname == "/abstracts") || (pathname == "/my_abstracts") || (pathname == "/my_abstracts/my")) {
        var tooltip = 'Filter abstract list by current selection status (oral, poster, rejected) or all.';
        var targetElement = "#abstractsStaticTable > thead > tr:nth-of-type(1)";
        customToolTips(targetElement, tooltip);
        activateSelectFilter();
    } else if (pathname == "/users") {
        var tooltip = 'Edit these parameters via Admin menu links.';
        var targetElement = "tr > td:nth-of-type(2), tr > td:nth-of-type(3), tr > td:nth-of-type(4)";
        customToolTips(targetElement, tooltip);
    } else if (pathPartsCount > 0) {
        var pathParts = pathname.split("/");
        if ((pathParts[1] == "abstracts") && (pathParts[3] == "edit")) {
            activateNewAuthor();
        } else if ((pathPartsCount == 2) && (pathParts[1] == "abstracts")) {
            var tooltip = "Scroll window for complete abstract."
            var targetElement = ".showAbstractScroll";
            customToolTips(targetElement, tooltip);
        }
    }

    // ======= activateSessionSelect =======
    function activateSessionSelect() {
        console.log("== activateSessionSelect ==");
        $('#invitedCheck').val();
    }

    // ======= saveAllChanges =======
    function saveAllChanges() {
        console.log("== saveAllChanges ==");
        console.log("$('#abstract_abs_comment').val():", $('#abstract_abs_comment').val());
        if ($('#abstract_abs_comment').val().length > 0) {
            $('.notice').html("Please save or cancel comment before submitting form.");
        } else {
            $("#save_all_reviews").submit();
        }
    }

    // ======= activateRevAbsBtns =======
    function activateRevAbsBtns() {
        console.log("== activateRevAbsBtns ==");
        $('.addCommentBtn').on('click', showCommentInput);
        $('#submitReviewBtn').on('click', saveAllChanges);
    }

    // ======= cancelCommentText =======
    function cancelCommentText() {
        console.log("== cancelCommentText ==");
        $('#abstract_abs_comment').val(null);
        $('#abstract_abs_comment').text(null);
        $('.commentBox').css('visibility', 'hidden');
    }

    // ======= saveCommentText =======
    function saveCommentText() {
        console.log("== saveCommentText ==");

        // ======= get selected data =======
        var url = "/save_abs_comment";
        var abstract_id = $('#abstract_id').val();
        var abstract_val = $('#abstract_abs_comment').val();
        var which_reviewer = $('#abstract_which_reviewers_' + abstract_id).val();
        var abstract_comment = $('#abstract_abs_comment').text();
        console.log("abstract_id:", abstract_id);
        console.log("abstract_val:", abstract_val);
        console.log("abstract_comment:", abstract_comment);
        console.log("$('#abstract_abs_comment1'):", $('#abstract_abs_comment'));

        $.ajax({
            url: url,
            data: {
                abstract_id: abstract_id,
                abstract_comment: abstract_val,
                which_reviewer: which_reviewer
            },
            method: "GET",
            dataType: "json"
        }).done(function(jsonData) {
            console.log("*** ajax success ***");
            console.dir(jsonData)
            $('.notice').html(jsonData.notice);
            $('#abstract_abs_comment').val(null);
            $('#abstract_abs_comment').text(null);
            console.log("$('#abstract_abs_comment2'):", $('#abstract_abs_comment'));
            $('.commentBox').css('visibility', 'hidden');
        }).fail(function(){
            console.log("*** ajax fail ***");
        }).error(function() {
            console.log("*** ajax error ***");
        });
    }

    // ======= showCommentInput =======
    function showCommentInput(e) {
        console.log("== showCommentInput ==");
        console.log("e.currentTarget.id:", e.currentTarget.id);
        var abstract_id = e.currentTarget.id.split("_")[1];
        var which_reviewer = $('#abstract_which_reviewers_' + abstract_id).val();
        console.log("abstract_id:", abstract_id);
        console.log("which_reviewer:", which_reviewer);
        $('#cancelCommentBtn').off('click', cancelCommentText);
        $('#cancelCommentBtn').on('click', cancelCommentText);
        $('#saveCommentBtn').off('click', saveCommentText);
        $('#saveCommentBtn').on('click', saveCommentText);
        $('#abstract_id').val(abstract_id);

        // ======= get selected data =======
        var url = "/get_abs_comment";

        $.ajax({
            url: url,
            data: {
                abstract_id: abstract_id,
                which_reviewer: which_reviewer
            },
            method: "GET",
            dataType: "json"
        }).done(function(jsonData) {
            console.log("*** ajax success ***");
            console.dir(jsonData)
            var abs_comment = jsonData.abs_comment;
            console.log("abs_comment:", abs_comment);
            $('#abstract_abs_comment').val(abs_comment);
            $('#abstract_abs_comment').text(abs_comment);
            $('.commentBox').css('visibility', 'visible');
            console.log("$('#abstract_abs_comment'):", $('#abstract_abs_comment'));
        }).fail(function(){
            console.log("*** ajax fail ***");
        }).error(function() {
            console.log("*** ajax error ***");
        });
    }

    // ======= customToolTips =======
    function customToolTips(targetElement, tooltip) {
        console.log("== customToolTips ==");
        $(targetElement).bind('mouseover', { param: tooltip }, toggleToolTips);
        $(targetElement).bind('mouseout', { param: "" }, toggleToolTips);
    }

    // ======= showAddAuthor =======
    function showAddAuthor() {
        console.log("== showAddAuthor ==");
        $('.newAuthorEntries').css('display', 'block');
        $('.newAuthorButton').css('display', 'none');
    }

    // ======= activateNewAuthor =======
    function activateNewAuthor() {
        console.log("== activateNewAuthor ==");
        $('#add_author').on('click', showAddAuthor);
    }

    // ======= toggleToolTips =======
    function toggleToolTips(e, param) {
        console.log("== toggleToolTips ==");
        if ($('.notice').text() == "") {
            $('.notice').text(e.data.param);
        } else {
            $('.notice').text('');
        }
    }

    // ======= checkSelectBox =======
    function checkSelectBox() {
        console.log("== checkSelectBox ==");
        console.log("$('#keywords').val():", $('#keywords').val());
        if ($('#keywords').val() == "0") {
            console.log("+++ notice +++");
            $('.notice').text('Please select a keyword before submitting');
        } else {
            console.log("+++ submit +++");
            $("#filter_by_keyword").submit();
        }
    }

    // ======= abstractBySelection =======
    function abstractBySelection() {
        console.log("== abstractBySelection ==");
        var selectType = $('#select_type').find(":selected").text();
        console.log("pathname:", pathname);
        console.log("selectType:", selectType);
        $("#my_abstracts").submit();
    }

    // ======= activateSelectFilter =======
    function activateSelectFilter() {
        console.log("== activateSelectFilter ==");
        $('#filter_abstracts').on('click', abstractBySelection);
    }

    // ======= activateSubmitSelection =======
    function activateSubmitSelection() {
        console.log("== activateSubmitSelection ==");
        $('.submit_selection').on('click', submitSelection);
        $('#save_all_selections').on('click', submitAllSelections);
        $('#filter_selections').on('click', checkSelectBox);
        $('#all_selections').on('click', getAllAbstracts);
    }

    // ======= getAllAbstracts =======
    function getAllAbstracts() {
        console.log("== getAllAbstracts ==");
        location.href = "/select_abstracts";
    }

    // ======= activateSubmitReviewers =======
    function activateSubmitReviewers() {
        console.log("== activateSubmitReviewers ==");
        $('.submit_reviewers').on('click', submitReviewers);
        $('#save_all_reviewers').on('click', submitAllReviewers);
    }

    // ======= submitSelection =======
    function submitSelection(e) {
        console.log("== submitSelection ==");
        e.preventDefault();
        var abstract_id = (e.currentTarget.id).split("_")[2];
        var admin_final = $('#abstract_admin_finals_' + abstract_id).val();
        $("#abstract_abstract_id").val(abstract_id);
        $("#abstract_admin_final").val(admin_final);
        $("#save_selection").submit();
    }

    // ======= submitReviewers =======
    function submitReviewers(e) {
        console.log("== submitReviewers ==");
        e.preventDefault();
        var abstract_id = (e.currentTarget.id).split("_")[2];
        var reviewer1_id = $('#abstract_reviewer1_ids_' + abstract_id).val();
        var reviewer2_id = $('#abstract_reviewer2_ids_' + abstract_id).val();
        console.log("abstract_id:", abstract_id);
        console.log("reviewer1_id:", reviewer1_id);
        console.log("reviewer2_id:", reviewer2_id);
        $("#abstract_reviewer1_id").val(reviewer1_id);
        $("#abstract_reviewer2_id").val(reviewer2_id);
        $("#abstract_abstract_id").val(abstract_id);
        $("#save_reviewers").submit();
    }

    // ======= submitAllSelections =======
    function submitAllSelections(e) {
        console.log("== submitAllSelections ==");
        e.preventDefault();
        $("#abstract_abstract_id").val("all");
        console.log("abstract_abstract_id", $("#abstract_abstract_id").val());
        $("#save_selection").submit();
    }

    // ======= submitAllReviewers =======
    function submitAllReviewers(e) {
        console.log("== submitAllReviewers ==");
        e.preventDefault();
        $("#abstract_abstract_id").val("all");
        console.log("abstract_abstract_id", $("#abstract_abstract_id").val());
        $("#save_reviewers").submit();
    }
});
