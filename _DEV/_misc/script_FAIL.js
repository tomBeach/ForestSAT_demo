$(document).on('turbolinks:load', function() {
    console.log("== turbolinks:load ==");

    // ======= check pathname =======
    var pathname = window.location.pathname;
    console.log("pathname:", pathname);

    // ======= window conditionals =======
    if (pathname == "/assign_reviewers") {
        console.log("PATHNAME: /assign_reviewers");
        activateSubmitReviewers();
    } else if ((pathname == "/select_abstracts") || (pathname == "/filter_by_keyword")) {
        console.log("PATHNAME: /select_abstracts");
        activateSubmitSelection();
    } else {
        // initAutoComplete();
    }

    // ======= activateSubmitSelection =======
    function activateSubmitSelection() {
        console.log("== activateSubmitSelection ==");
        $('.submit_selection').on('click', submitSelection);
        $('#save_all_selections').on('click', submitAllSelections);
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
            $('.titleRow_4').css('display', 'block');
            $('#cancelBtn_1').on('click', abstractMgr.cancelAbstractSubmit);
            $('#nextBtn_1').on('click', abstractMgr.nextInputView);
        },

        // ======= addNewAuthor =======
        addNewAuthor: function(e) {
            console.log("== addNewAuthor ==");
            console.log("abstractMgr.secondaryAuthorIndex:", abstractMgr.secondaryAuthorIndex);
            e.preventDefault();
            abstractMgr.secondaryAuthorIndex = abstractMgr.secondaryAuthorIndex + 1;
            var authorIndex = abstractMgr.secondaryAuthorIndex;
            var authorHtml = "";
            authorHtml += "<div id='secondary_" + authorIndex + "'>";

            // == author names inputs
            authorHtml += "<input type='text' name='author[firstnames][]' id='firstname_" + authorIndex + "' class='dataEntry secAuthor'>";
            authorHtml += "<input type='text' name='author[lastnames][]' id='lastname_" + authorIndex + "' class='dataEntry secAuthor sec_2'>";

            // == author type
            authorHtml += "<input type='hidden' name='abstract_author[author_types][]' id='abstract_author_author_types_' value='secondary'>"

            // == presenting radios
            authorHtml += "<input class='presenting' type='radio' value='" + authorIndex + "' name='abstract[pres_author_id]' id='abstract_pres_author_id_true' class='sec_3'>";
            authorHtml += "<i class='radioLabel'>presenting</i>";

            // == affiliations
            authorHtml += "<input type='text' name='affiliation[institutions][]' id='sec_institution_" + authorIndex + "' class='dataEntry leftEntry secAuthor sec_4'>";
            authorHtml += "<input type='text' name='affiliation[departments][]' id='sec_department_" + authorIndex + "' class='dataEntry secAuthor'>";
            authorHtml += "</div>";
            console.log("authorHtml:", authorHtml);
            $('.scrollBox').append(authorHtml);
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
                $('.titleRow_2, .titleRow_3, .titleRow_4').css('display', 'block');

                // == activate/dectivate adjacent and current buttons
                $('#cancelBtn_1').on('click', abstractMgr.cancelAbstractSubmit);
                $('#nextBtn_1').on('click', abstractMgr.nextInputView);
                $('#cancelBtn_2, #cancelBtn_3, #cancelBtn_4').off('click', abstractMgr.nextInputView);
                $('#nextBtn_2, #nextBtn_3, #nextBtn_4').off('click', abstractMgr.nextInputView);
                $('#prevBtn_2, #prevBtn_3, #prevBtn_4').off('click', abstractMgr.prevInputView);
            }

            // == author screen
            if (index == 1) {
                // == hide adjacent rows
                $('.titleRow_2, .titleRow_3, .titleRow_4').css('display', 'none');
                $('.textRow_2, .textRow_3, .textRow_4').css('display', 'none');

                // == show current rows
                $('.authorRow_2, .authorRow_3, .authorRow_4').css('display', 'block');

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
                $('.textRow_2, .textRow_3, .textRow_4').css('display', 'block');

                // == activate/dectivate adjacent and current buttons
                $('#cancelBtn_3').on('click', abstractMgr.cancelAbstractSubmit);
                $('#nextBtn_3').on('click', abstractMgr.nextInputView);
                $('#prevBtn_3').on('click', abstractMgr.prevInputView);
                $('#authorBtn').off('click', abstractMgr.addNewAuthor);
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
                $('.keywordRow_4').css('display', 'block');

                // == activate/dectivate adjacent and current buttons
                $('#cancelBtn_4').on('click', abstractMgr.cancelAbstractSubmit);
                $('#nextBtn_4').on('click', abstractMgr.nextInputView);
                $('#prevBtn_4').on('click', abstractMgr.prevInputView);
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
                    abstractMgr.toggleInputView(-2);
                }
            }
        }
    }
    abstractMgr.initialize()
});
