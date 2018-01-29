$(document).on('turbolinks:load', function() {
    console.log("== turbolinks:load ==");

    // ======= ======= ======= abstractMgr ======= ======= =======
    // ======= ======= ======= abstractMgr ======= ======= =======
    // ======= ======= ======= abstractMgr ======= ======= =======

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

            // == count number of secondary authors (to increment id index for new author inputs)
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
            authorHtml += "<input class='presenting' type='radio' value='" + authorIndex + "' name='abstract[pres_author_id]' id='abstract_pres_author_id_true'>";
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
                $('.invited_entries > span:nth-of-type(2) > i').text('for which special session?');
            } else {
                $('.sessionLabel').css('display', 'block');
                $('.invited_entries > span:nth-of-type(2) > i').text('select a session');
            }
        },

        // ======= cancelAbstractSubmit =======
        cancelAbstractSubmit: function() {
            console.log("== cancelAbstractSubmit ==");
            location.href = "/home";
        },

        // ======= prevInputView =======
        prevInputView: function(e) {
            console.log("== prevInputView ==");
            abstractMgr.toggleInputView(-1);
            e.preventDefault();
            $('.notice').text('');
        },

        // ======= validateAuthors =======
        validateAuthors: function(e) {
            console.log("== validateAuthors ==");
            var authorDataEls = $('.authorEntry');
            var authorsValid = true;
            for (var i = 0; i < authorDataEls.length; i++) {
                if ($(authorDataEls[i]).val().length < 1) {
                    $(authorDataEls[i]).css('border', 'solid red 2px');
                    authorsValid = false;
                } else {
                    $(authorDataEls[i]).css('border', '');
                }
            }
            return authorsValid;
        },

        // ======= validatePresenters =======
        validatePresenters: function(e) {
            console.log("== validatePresenters ==");
            var presentingDataEls = $('.presenting');
            var presentingValid = false;
            var authorDataEls = $('.dataEntry');
            for (var i = 0; i < presentingDataEls.length; i++) {
                if ($(presentingDataEls[i]).is(':checked')) {
                    if (i > 0) {
                        if ($(authorDataEls).eq((i-1)*4).val().length > 0) {
                            presentingValid = true;
                        } else {
                            presentingValid = "missing author";
                        }
                    } else {
                        presentingValid = true;
                    }
                }
            }
            return presentingValid;
        },

        // ======= validateKeywordSelects =======
        validateKeywordSelects: function() {
            console.log("== validateKeywordSelects ==");
            var selectionLength;
            var keywordsValid = "";
            var keywordsSelected = [];
            var keywordSelectEls = $('.keywordEntry');
            for (var i = 0; i < keywordSelectEls.length; i++) {
                selectionLength = $(keywordSelectEls[i]).val().length;
                if (selectionLength > 0) {
                    if (keywordsSelected.indexOf($(keywordSelectEls[i]).val()) == -1) {
                        keywordsSelected.push($(keywordSelectEls[i]).val());
                    } else {
                        keywordsValid = "duplicates";
                    }
                }
            }
            if (keywordsSelected.length < 1) {
                keywordsValid = "invalid";
            }
            return keywordsValid;
        },

        // ======= validateSessionSelect =======
        validateSessionSelect: function() {
            console.log("== validateSessionSelect ==");
            var inviteCheckEl = $('#invitedCheck');
            var checked = $('#invitedCheck:checked').length;
            console.log("checked:", checked);
            if (checked > 0) {
                var sessionSelectEl = $('#abstract_presentation_id');
                var selected = $("#abstract_presentation_id option:selected").index()
                console.log("selected:", selected);
                if (selected > 0) {
                    var sessionValid = "valid";
                } else {
                    var sessionValid = "invalid";
                }
            } else {
                var sessionValid = "valid";
            }
            console.log("sessionValid:", sessionValid);
            return sessionValid;
        },

        // ======= nextInputView =======
        nextInputView: function(e) {
            console.log("== nextInputView ==");
            e.preventDefault();
            var index = abstractMgr.currentInputsIndex;
            var msgText = "";
            switch (index) {
                case 0:
                    if ($('#abstract_abs_title').val().length > 0) {
                        $('#abstract_abs_title').data('valid','1');
                        $('#abstract_abs_title').css('border', '');
                        abstractMgr.toggleInputView(1);
                    } else {
                        $('#abstract_abs_title').data('valid','0');
                        $('#abstract_abs_title').css('border', 'solid red 2px');
                        msgText = "Please enter a title before continuing."
                    }
                    break;
                case 1:
                    var authorsValid = abstractMgr.validateAuthors();
                    if (authorsValid) {
                        $('.authorEntry').eq(0).data('valid','1');
                        var presentingValid = abstractMgr.validatePresenters();
                        if (presentingValid == "missing author") {
                            msgText = "Presenting author data must be entered.";
                            presentingValid = false;
                        } else if (presentingValid) {
                            $('.authorEntry').eq(1).data('valid','1');
                            abstractMgr.toggleInputView(1);
                        } else {
                            $('.authorEntry').eq(1).data('valid','0');
                            msgText = "Please select a presenting author."
                        }
                    } else {
                        $('.authorEntry').eq(0).data('valid','0');
                        msgText = "Please make sure all fields are filled in."
                    }
                    break;
                case 2:
                    if ($('#abstract_abs_text').val().length > 0) {
                        $('#abstract_abs_text').data('valid','1');
                        $('#abstract_abs_text').css('border', '');
                        abstractMgr.toggleInputView(1);
                    } else {
                        $('#abstract_abs_text').data('valid','0');
                        $('#abstract_abs_text').css('border', 'solid red 2px');
                        msgText = "Please enter the abstract text before continuing."
                    }
                    break;
                case 3:
                    var keywordsValid = abstractMgr.validateKeywordSelects();
                    if (keywordsValid == "invalid") {
                        msgText = "Please select at least one keyword."
                    } else if (keywordsValid == "duplicates") {
                        msgText = "Please check keyword selections for duplication."
                    } else {
                        $('#abstract_abs_text').data('valid','1');
                        var sessionValid = abstractMgr.validateSessionSelect();
                        if (sessionValid != "valid") {
                            msgText = "Please select a special session for your invited abstract."
                        } else {
                            $('#abstract_abs_text').data('valid','1');
                            abstractMgr.toggleInputView(1);
                        }
                    }
                    break;
            }
            $('.notice').text(msgText);
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

            // == title screen ======= ======= ======= ====== =======
            if (index == 0) {

                // == hide author screen rows (arrival via PREV button)
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

            // == author screen ======= ======= ======= ====== =======
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

            // == text screen ======= ======= ======= ====== =======
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
                $('.keywordEntry').off('change', abstractMgr.validateKeywordSelects);
                $('#authorBtn').off('click', abstractMgr.addNewAuthor);
                $('#invitedCheck').off('click', abstractMgr.toggleSessionSelect);
                $('#cancelBtn_1, #cancelBtn_2, #cancelBtn_4').off('click', abstractMgr.cancelAbstractSubmit);
                $('#nextBtn_1, #nextBtn_2, #nextBtn_4').off('click', abstractMgr.nextInputView);
                $('#prevBtn_1, #prevBtn_2, #prevBtn_4').off('click', abstractMgr.prevInputView);
            }

            // == keyword/request screen ======= ======= ======= ====== =======
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
                $('.keywordEntry').on('change', abstractMgr.validateKeywordSelects);
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

            // == submit after validation ======= ======= ======= ====== =======
            if (index == 4) {

                $('.keywordRow_2, .keywordRow_3, .keywordRow_4').css('display', 'none');
                $('#secondary_authors').append(abstractMgr.firstnames);
                $('#secondary_authors').append(abstractMgr.lastnames);
                $('#secondary_authors').append(abstractMgr.institutions);
                $('#secondary_authors').append(abstractMgr.departments);
                $('#secondary_authors').append(abstractMgr.author_types);
                $('#nextBtn_4').text('submit');
                $("#new_abstract").submit();
            }
        }
    }
    abstractMgr.initialize();
});
