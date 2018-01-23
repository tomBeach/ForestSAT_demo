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
        var tooltip = "Click link to see abstract details."
        var targetElement = "#selabsScrollTable > tbody > tr > td:nth-of-type(1) > a";
        customToolTips(targetElement, tooltip);
        activateSubmitSelection();
    } else if (pathname == "/users") {
        var tooltip = 'Edit these parameters via Admin menu links.';
        var targetElement = "tr > td:nth-of-type(2), tr > td:nth-of-type(3), tr > td:nth-of-type(4)";
        customToolTips(targetElement, tooltip);
    } else if (pathPartsCount > 0) {
        var pathParts = pathname.split("/");
        if ((pathParts[1] == "abstracts") && (pathParts[3] == "edit")) {
            activateNewAuthor();
        } else if ((pathPartsCount == 2) && (pathParts[1] == "abstracts")) {
            var tooltip = "Scroll window for additional options."
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

    var abstractMgr = {
        secondaryAuthorIndex: 1,
        currentInputsIndex: 0,
        firstnames: null,
        lastnames: null,
        institutions: null,
        departments: null,
        author_types: null,

        // ======= initialize =======
        initialize: function() {
            console.log("== initialize ==");
            $('.titleRow_2').css('display', 'block');
            $('.titleRow_3').css('display', 'block');
            $('.titleRow_4').css('display', 'flex');
            $('#cancelBtn_1').on('click', abstractMgr.cancelAbstractSubmit);
            $('#nextBtn_1').on('click', abstractMgr.nextInputView);
        },

        // ======= addNewAuthor =======
        addNewAuthor: function(e) {
            console.log("== addNewAuthor ==");
            e.preventDefault();
            abstractMgr.secondaryAuthorIndex = abstractMgr.secondaryAuthorIndex + 1;
            var authorIndex = abstractMgr.secondaryAuthorIndex;
            var authorHtml = "";
            authorHtml += "<div id='secondary_" + authorIndex + "' class=''>";

            // == author names inputs
            authorHtml += "<input type='text' name='author[firstnames][]' id='firstname_" + authorIndex + "' value='' class='dataEntry secAuthor'>";
            authorHtml += "<input type='text' name='author[lastnames][]' id='lastname_" + authorIndex + "' value='' class='dataEntry secAuthor'>";

            // == author type
            authorHtml += "<input type='hidden' name='abstract_author[author_types][]' id='abstract_author_author_types_' value='secondary' class='author author_type'>"

            // == presenting radios
            authorHtml += "<input class='' type='radio' value='" + authorIndex + "' name='abstract[pres_author_id]' id='abstract_pres_author_id_true'>";
            authorHtml += "<i class='radioLabel'>presenting</i>";

            // == affiliations
            authorHtml += "<input type='text' name='affiliation[institutions][]' id='sec_institution_" + authorIndex + "' value='' class='dataEntry leftEntry secAuthor'>";
            authorHtml += "<input type='text' name='affiliation[departments][]' id='sec_department_" + authorIndex + "' value='' class='dataEntry secAuthor lastDept'>";
            authorHtml += "</div>";
            console.log("authorHtml:", authorHtml);
            $('.scrollBox').append(authorHtml);
        },

        // ======= toggleSessionSelect =======
        toggleSessionSelect: function() {
            console.log("== toggleSessionSelect ==");
            if ($('.sessionLabel').css('display') == 'block') {
                $('.sessionLabel').css('display', 'none');
                // $('.invited_entries > span:nth-of-type(1) > i').text('for which session?');
                $('.invited_entries > span:nth-of-type(2) > i').text('for which special session?');
            } else {
                $('.sessionLabel').css('display', 'block');
                // $('.invited_entries > span:nth-of-type(1) > i').text('check if invited');
                $('.invited_entries > span:nth-of-type(2) > i').text('select a session');
            }
        },

        // ======= cancelAbstractSubmit =======
        cancelAbstractSubmit: function() {
            console.log("== cancelAbstractSubmit ==");
            location.href = "/home";
        },

        // ======= submitAbstractForm =======
        submitAbstractForm: function() {
            console.log("== submitAbstractForm ==");
            $("#new_abstract").submit();
        },

        // ======= prevInputView =======
        prevInputView: function(e) {
            console.log("== prevInputView ==");
            abstractMgr.toggleInputView(-1);
            e.preventDefault();
        },

        // ======= nextInputView =======
        nextInputView: function(e) {
            console.log("== nextInputView ==");
            abstractMgr.toggleInputView(1);
            e.preventDefault();
        },

        // ======= toggleInputView =======
        toggleInputView: function(inc_dec) {
            console.log("== toggleInputView ==");
            console.log("inc_dec:", inc_dec);

            var index = abstractMgr.currentInputsIndex;
            var adminFlag = $('#admin_flag').val();

            // == increase or decrease index
            index += inc_dec;
            if (index < 0) {
                index = 4;
            } else if (index >= 5) {
                index = 0;
            }
            console.log("index:", index);

            // == update master index
            abstractMgr.currentInputsIndex = index;

            // == title screen
            if (index == 0) {
                // == hide adjacent rows
                $('.authorRow_2, .authorRow_3, .authorRow_4').css('display', 'none');

                // == show current rows
                $('.titleRow_2, .titleRow_3').css('display', 'block');
                $('.titleRow_4').css('display', 'flex');

                // == activate/dectivate adjacent and current buttons
                $('#cancelBtn_1').on('click', abstractMgr.cancelAbstractSubmit);
                $('#nextBtn_1').on('click', abstractMgr.nextInputView);
                $('#cancelBtn_2, #cancelBtn_3, #cancelBtn_4').off('click', abstractMgr.nextInputView);
                $('#nextBtn_2, #nextBtn_3, #nextBtn_4').off('click', abstractMgr.nextInputView);
                $('#prevBtn_2, #prevBtn_3, #prevBtn_4').off('click', abstractMgr.prevInputView);
                $('#authorBtn').off('click', abstractMgr.addNewAuthor);
            }

            // == author screen
            if (index == 1) {
                // == hide adjacent rows
                $('.keywordRow_2, .keywordRow_3, .keywordRow_4').css('display', 'none');
                $('.titleRow_2, .titleRow_3, .titleRow_4').css('display', 'none');
                $('.textRow_2, .textRow_3, .textRow_4').css('display', 'none');

                // == show current rows
                $('.authorRow_2, .authorRow_3').css('display', 'block');
                $('.authorRow_4').css('display', 'flex');

                // == activate/dectivate adjacent and current buttons
                $('#cancelBtn_2').on('click', abstractMgr.cancelAbstractSubmit);
                $('#nextBtn_2').on('click', abstractMgr.nextInputView);
                $('#prevBtn_2').on('click', abstractMgr.prevInputView);
                $('#authorBtn').on('click', abstractMgr.addNewAuthor);
                $('#cancelBtn_1, #cancelBtn_3, #cancelBtn_4').off('click', abstractMgr.cancelAbstractSubmit);
                $('#nextBtn_1, #nextBtn_3, #nextBtn_4').off('click', abstractMgr.nextInputView);
                $('#prevBtn_1, #prevBtn_3, #prevBtn_4').off('click', abstractMgr.prevInputView);
            }

            // == text screen
            if (index == 2) {
                // == hide adjacent rows
                $('.authorRow_2, .authorRow_3, .authorRow_4').css('display', 'none');
                $('.keywordRow_2, .keywordRow_3, .keywordRow_4').css('display', 'none');

                // == show current rows
                $('.textRow_2, .textRow_3').css('display', 'block');
                $('.textRow_4').css('display', 'flex');

                // == activate/dectivate adjacent and current buttons
                $('#cancelBtn_3').on('click', abstractMgr.cancelAbstractSubmit);
                $('#nextBtn_3').on('click', abstractMgr.nextInputView);
                $('#prevBtn_3').on('click', abstractMgr.prevInputView);
                $('#authorBtn').off('click', abstractMgr.addNewAuthor);
                $('#invitedCheck').off('click', abstractMgr.toggleSessionSelect);
                $('#cancelBtn_1, #cancelBtn_2, #cancelBtn_4').off('click', abstractMgr.cancelAbstractSubmit);
                $('#nextBtn_1, #nextBtn_2, #nextBtn_4').off('click', abstractMgr.nextInputView);
                $('#prevBtn_1, #prevBtn_2, #prevBtn_4').off('click', abstractMgr.prevInputView);
            }

            // == keyword/request screen
            if (index == 3) {
                // == hide adjacent rows
                $('.textRow_2, .textRow_3, .textRow_4').css('display', 'none');

                // == show current rows
                $('.keywordRow_2, .keywordRow_3').css('display', 'block');
                if (adminFlag == "true") {
                    $('.adminInfo').css('display', 'block');
                    $('#abstract_keyword_1, #abstract_keyword_2, #abstract_keyword_3').css('display', 'block');
                } else {
                    $('.adminInfo').css('display', 'none');
                    $('#new_keyword_1, #new_keyword_2, #new_keyword_3').css('display', 'none');
                }
                $('.keywordRow_4').css('display', 'flex');

                // == activate/dectivate adjacent and current buttons
                $('#cancelBtn_4').on('click', abstractMgr.cancelAbstractSubmit);
                $('#nextBtn_4').on('click', abstractMgr.nextInputView);
                $('#prevBtn_4').on('click', abstractMgr.prevInputView);
                $('#invitedCheck').on('click', abstractMgr.toggleSessionSelect);
                $('#cancelBtn_1, #cancelBtn_2, #cancelBtn_3').off('click', abstractMgr.cancelAbstractSubmit);
                $('#nextBtn_1, #nextBtn_2, #nextBtn_3').off('click', abstractMgr.nextInputView);
                $('#prevBtn_1, #prevBtn_2, #prevBtn_3').off('click', abstractMgr.prevInputView);

                var firstnames = $('.firstname').map(function(){return $(this).val();}).get();
                var lastnames = $('.lastname').map(function(){return $(this).val();}).get();
                var institutions = $('.institution').map(function(){return $(this).val();}).get();
                var departments = $('.department').map(function(){return $(this).val();}).get();
                var author_types = $('.author_type').map(function(){return $(this).val();}).get();

                var presentingRadios = $('.presenting')
                var checkedRadio = $('.presenting:checked', '#new_abstract').val()

                abstractMgr.firstnames = firstnames;
                abstractMgr.lastnames = lastnames;
                abstractMgr.institutions = institutions;
                abstractMgr.departments = departments;
                abstractMgr.author_types = author_types;
            }

            // == submit after validation
            if (index == 4) {
                if ($("input[name='abstract[pres_author_id]']:checked").length) {
                    $('.keywordRow_2, .keywordRow_3, .keywordRow_4').css('display', 'none');
                    $('#secondary_authors').append(abstractMgr.firstnames);
                    $('#secondary_authors').append(abstractMgr.lastnames);
                    $('#secondary_authors').append(abstractMgr.institutions);
                    $('#secondary_authors').append(abstractMgr.departments);
                    $('#secondary_authors').append(abstractMgr.author_types);
                    $('#nextBtn_4').text('submit');
                    $("#new_abstract").submit();
                } else {
                    $('.notice').text('Please select a presenting author.');
                    abstractMgr.toggleInputView(-3);
                }
            }
        }
    }
    abstractMgr.initialize()
});
