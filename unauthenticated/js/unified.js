window.onerror = function(errMsg, url, lineNumber, colNum, err) {
    // alert("Error caught");
    $('#content').html(
        url + ' - ' +
        lineNumber + ': ' +
        '<strong>' +
        errMsg +
        '</strong>'
    );
    $('#content').stop(true, true).scrollTop(0).fadeTo('fast', 1);
    $('.enscroll-track').stop(true, true).scrollTop(0).fadeTo('fast', 1);
    $('.rotor').fadeOut('fast');
    console.log(err);
};

$(document).on('submit', 'form', function (e) {
    e.preventDefault();
    $('#content').fadeTo('fast', 0);
    $('.enscroll-track').fadeTo('fast', 0);
    $('.rotor').fadeIn('fast');
    var $form = $(this);
    var url = $form.attr('action');
    var progress = 0;
    var unbuffered = false;
    if(this.method == "post") {     //While submitting post form, response sometimes come in chunks.
        $.ajax({                    // Deal with it!
            url: this.action,
            data: $form.serialize(),
            method: 'POST',
            xhr: function () {
                var xhr = new window.XMLHttpRequest();
                xhr.addEventListener("progress", function (evt) {   //INCOMING!!!
                    if(progress === 0) {
                        if(xhr.responseText.indexOf('<i data="unbuffered"></i>') > -1) {
                            $('#content').html('');
                            unbuffered = true;
                            $('#content').stop(true, true).scrollTop(0).fadeTo('fast', 1);
                            $('.enscroll-track').stop(true, true).scrollTop(0).fadeTo('fast', 1);
                        }
                    }
                    if(unbuffered) {
                        var html = '<div>' + xhr.responseText.substring(progress) + '</div>';
                        var div = $(html).hide().appendTo('#content')
                        $(div).fadeIn('fast', function() {
                            $(this).contents().unwrap();    //Niiiice
                        })
                        $('#content').scrollTop(0 + $('#content')[0].scrollHeight);
                        // $('#content').stop(true, true).animate({
                        //     scrollTop: 0 + $('#content')[0].scrollHeight
                        // }, 200);
                        progress = evt.loaded;
                    }
                }, false);
                return xhr;
            },
        })
        .done(function(response) {
            if(unbuffered) {
                updateContent(response, url);
            } else {
                $('#content').html(response);
                updateContent(response, url);
                $('#content').stop(true, true).fadeTo('fast', 1);
                $('.enscroll-track').stop(true, true).fadeTo('fast', 1);
            }
            $('.rotor').fadeOut('fast');
        });
        // .always(function(response) {
        //     // updateContent(response, url);
        //     // $('#content').stop(true, true).scrollTop(0).fadeTo('fast', 1);
        //     // $('.enscroll-track').stop(true, true).scrollTop(0).fadeTo('fast', 1);
        //     makeRock(url);
        //     $('#content').stop(true, true).fadeTo('fast', 1);
        //     $('.enscroll-track').stop(true, true).fadeTo('fast', 1);
        //     $('.rotor').fadeOut('fast');
        // });
    } else {
        $.get(this.action, $form.serialize())
        .always(function(response) {
            $('#content').html(response);
            updateContent(response, url);
            $('#content').stop(true, true).scrollTop(0).fadeTo('fast', 1);
            $('.enscroll-track').stop(true, true).scrollTop(0).fadeTo('fast', 1);
            $('.rotor').fadeOut('fast');
        });
    }
});

$(document).on('click', 'a.ajax', function(e) {
    e.preventDefault();
    var url = $(this).attr('href');
    $('#content').fadeTo('fast', 0);
    $('.enscroll-track').fadeTo('fast', 0);
    $('.rotor').fadeIn('fast');
    $('#content').html('');
    var progress = 0;
    $.ajax({
        url: url,
        async: true,
        dataType: 'text',
    })
    .done(function(response) {
        $('#content').html(response);
        updateContent(response, url);
    })
    .always(function() {
        $('#content').stop(true, true).scrollTop(0).fadeTo('fast', 1);
        $('.enscroll-track').stop(true, true).scrollTop(0).fadeTo('fast', 1);
        $('.rotor').fadeOut('fast');
    });
});

/* Fix table filter 0x0D form submission*/
$(document).on("keydown", ".filterControl input", function(event) {
    if (event.which == 13) {
        event.preventDefault();
    }
});

/* Help link click */
$(document).on('click', 'a.help', function(e) {
    e.preventDefault();
    var url = $(this).attr('href');
    $.ajax({
        url: url,
        async: true,
        dataType: 'html'
    })
    .done(function(response) {
        url = url.substring(0, url.lastIndexOf('/'));
        $('#help-dialog .modal-body').html(response);
        $('#help-dialog').modal();
    });
});

/* Chooser */
$(document).on('click', '.chooser-open', function(e) {
    e.preventDefault();
    var url = $(this).attr('data-url');
    ifield = this.form[$(this).attr('data-field')];
    var singleSelect = ifield.type == 'text';
    url += encodeURIComponent(ifield.value);
    $chooser = $('#modal');
    $chooser.data.ifield = ifield;
    $.ajax({
        url: url,
        async: true,
        dataType: 'html'
    })
    .done(function(response) {
        $chooser.find('.modal-body').html(response);
        $chooser.find('.modal-body').fadeTo(0, 0);
        $chooser.modal()
        .off('shown.bs.modal')
        .on('shown.bs.modal', function(e) {
            $chooser.find('.modal-body [data-toggle="table"]').each(function(index, table) {
                $(table).bootstrapTable({
                    classes: 'table-condensed table-hover table-no-bordered',
                    escape: false,
                    filterControl: true,
                    height: $(window).height() - 200,
                    clickToSelect: true,
                    singleSelect: singleSelect,
                    columns: [{
                        checkbox: true,
                    }, {
                        field: 'name',
                        width: '50%'
                    }, {
                        field: 'size'
                    }, {
                        field: 'date'
                    }, {
                        field: 'time'
                    }]
                });
                $(table).find('.filterControl input').addClass('input-sm');
                $(table).parent().enscroll({
                    addPaddingToPane: false,
                    scrollIncrement: 50,
                });
            });
            $chooser.find('.modal-body select').each(function(index, select) {
                var liveSearch = select.length > 8;
                $(select).selectpicker({
                    style: 'btn-default btn-sm',
                    size: 8,
                    liveSearch: liveSearch,
                    actionsBox: true
                });
            })
            .on('shown.bs.select', function() {
                 $(this).prev('div.dropdown-menu').find('ul').enscroll({
                    addPaddingToPane: false,
                    scrollIncrement: 100,
                });
            });
            $chooser.find('.modal-body').fadeTo('fast', 1);
            $chooser.data.path = ifield.value;
        });
    });
});

$(document).on('click', 'a.chooser-url[href]', function(e) {
    e.preventDefault();
    $('#modal .modal-body').fadeTo(100, 0);
    var url = $(this).attr('href');
    var path = $(this).data('file');
    var singleSelect = $('#modal').data.ifield.type == 'text';
    $.ajax({
        url: url,
        async: true,
        dataType: 'html'
    })
    .done(function(response) {
        $('#modal .modal-body').html(response);
        $('#modal .modal-body').stop(true, true).fadeTo(100, 1);
        $('#modal .modal-body [data-toggle="table"]').each(function(index, table) {
            $(table).bootstrapTable({
                classes: 'table-condensed table-hover table-no-bordered',
                escape: false,
                filterControl: true,
                height: $(window).height() - 200,
                clickToSelect: true,
                singleSelect: singleSelect,
                columns: [{
                    checkbox: true,
                }, {
                    field: 'name',
                    width: '50%'
                }, {
                    field: 'size'
                }, {
                    field: 'date'
                }, {
                    field: 'time'
                }]
            });
            $(table).find('.filterControl input').addClass('input-sm');
            $(table).parent().enscroll({
                addPaddingToPane: false,
                scrollIncrement: 50,
            });
            $chooser.data.path = path;
        });
    });
});

$(document).on('click', 'a.chooser-url:not([href])', function() {
    var file = $(this).data('file');
    $chooser = $('#modal');
    $chooser.data.ifield.value = file;
    $chooser.modal('hide');
});

$(document).on('click', 'a.user-chooser', function() {
    var user = $(this).data('user');
    $chooser = $('#modal');
    $chooser.data.ifield.value = user;
    $chooser.modal('hide');
});

$(document).on('click', '.chooser-success', function(){
    var file = $(this).next('a.chooser-url').data('file');
    $chooser = $('#modal');
    if($('#modal').data.ifield.type == 'text') {
        $chooser.data.ifield.value = file;
    } else {
        $chooser.data.ifield.value += file + '\n';
    }

    $chooser.modal('hide');
});
/* End: File chooser */

$(document).ready(function() {
    $('.rotor').hide();
    $('#content').enscroll({
        addPaddingToPane: false,
        scrollIncrement: 50,
        // horizontalScrolling: true
    });

    $('#content').scroll(function () {
        if ($(this).scrollTop() > 100) {
            $('.scrollup').fadeIn();
        } else {
            $('.scrollup').fadeOut();
        }
    });

    $('.scrollup').click(function () {
        $('#content').animate({
            scrollTop: 0
        }, 300);
        return false;
    });

    $('#modal button').on('click', function(e) {
        $chooser = $('#modal');
        if($chooser.data.ifield) {
            var selected = $chooser.find('[data-toggle="table"]').bootstrapTable('getAllSelections');
            var singleSelect = $('#modal').data.ifield.type == 'text';
            if(selected.length > 0) {
                $.each(selected, function(index, row) {
                    if(singleSelect) {
                        $chooser.data.ifield.value = $(row.name).data('file');
                    } else {
                        $chooser.data.ifield.value += $(row.name).data('file') + '\n';
                    }
                });
            } else {
                if(singleSelect) {
                    $chooser.data.ifield.value = $chooser.data.path;
                } else {
                    $chooser.data.ifield.value += $chooser.data.path + '\n';
                }
            }
            $chooser.data.ifield = undefined;
        }
    });
    
    $('.nav-pills a').hover(function() {
        // $(this).tab('show');
    });
    $('.nav .dropdown-menu .nav-tabs a').click(function(e) {
        e.preventDefault();
        e.stopPropagation();
        $(this).tab('show');
    });

    /* Make domain selector cool */
    $('select').each(function(index, select) {
        var liveSearch = select.length > 8;
        $(select).selectpicker({
            style: 'btn-default btn-sm',
            size: 8,
            liveSearch: liveSearch,
            actionsBox: true
        });
    })
});

function updateContent(response, url) {
    url = url.substring(0, url.lastIndexOf('/'));
    // $('#content').html(response);
    //Костыли, костылики
    /* Setup tables */
    $('#content [data-toggle="table"]').each(function(index, table) {
        // Skip tables with no header
        var head = $(table).has('thead')[0];
        // console.log(table)
        if(head) {
            try {
                $(table).bootstrapTable({
                    classes: 'table-condensed table-hover table-no-bordered',
                    escape: false,
                    filterControl: true,
                    // stickyHeader: true,
                    // stickyHeaderOffsetY: '600px'
                });
                $(table).find('.filterControl input').addClass('input-sm');
            } catch(err) {
                console.log(err);
            }
        }
    });
    
    /* Enscroll textareas */
    $('textarea').enscroll({
        addPaddingToPane: false,
        scrollIncrement: 50,
    });

    /* Make selects rock */
    $('#content select').each(function(index, select) {
        // console.log(select.id);
        var liveSearch = select.length > 8;
        // Опять костыли
        if(select.name != 'mins' && select.name != 'hours' && select.name != 'days') {
            $(select).selectpicker({
                style: 'btn-default btn-sm',
                size: 8,
                liveSearch: liveSearch,
                actionsBox: true
            });
            // Нужно больше костылей
            $(select).attrchange({
                trackValues: true,
                callback: function(e) {
                    console.log(e)
                    if(e.attributeName == 'disabled' && e.newValue == 'disabled') {
                        // $('[data-id="' + select.id + '"').addClass('disabled')
                        $(select).prevAll('.dropdown-toggle').addClass('disabled');
                    } else if(e.attributeName == 'disabled' && e.newValue == undefined) {
                        // $('[data-id="' + select.id + '"').removeClass('disabled')
                        $(select).prevAll('.dropdown-toggle').removeClass('disabled');
                    }
                }
            });
        }
    })
    .on('shown.bs.select', function() {
         $(this).prev('div.dropdown-menu').find('ul').enscroll({
            addPaddingToPane: false,
            scrollIncrement: 100,
        });
    });
    $('#content .bootstrap-select input[type="text"]').addClass('input-sm');

    /* Make date time pickers cool */
    $('#content .date-time-picker').datetimepicker({
        useCurrent: false,
        format: 'DD/MM/YYYY',
    })
    .on('dp.change', function(e) {
        var form = this.form;
        var fDay = $(this).data('day');
        var fMonth = $(this).data('month');
        var fYear = $(this).data('year');
        var dmy = this.value.split('/');
        form[fDay].value = dmy[0];
        form[fMonth].value = dmy[1];
        form[fYear].value = dmy[2];
    });

    /* Ajaxify everything */
    $.each($('#content a[href]:not(.ajax):not(.ui_tab):not(.help):not([data-toggle]):not([target])'),
    function(index, link) {
        if($(link).attr('href').indexOf(url) !== 0 & $(link).attr('href').indexOf('/') !==0) {
            $(link).attr('href', url + '/' + $(link).attr('href'));
        }
        $(link).addClass('ajax');
    });

    /* Fix inputs created without ui-lib.pl */
    $.each($('#content input[type="submit"]:not(.btn)'),
    function(index, input) {
        $(input).addClass('btn btn-default btn-sm');
    });

    /* Select onChange autosubmission prevent */
    $.each($('#content select[onchange]'), function(index, select) {
        $(select).attr('onchange', '');
        $(select).addClass('select-auto-submit');
    });
}

$(document).on('change', '.select-auto-submit', function(e) {
    e.preventDefault();
    e.stopPropagation();
//    e.target.form.submit();
});

/* Dynamically reload virtul server menu */
$(document).on('change', '#domain-selector', function() {
    var that = this;
    // $('.vlink').each(function(index, link) {
    //     $(this).attr('href', $(this).attr('href').replace(/(dom=)[^\&]+/,'$1' + that.value));
    //     $(this).attr('href', $(this).attr('href').replace(/(parent=)[^\&]+/,'$1' + that.value));
    // });
    var url = 'get_domain_menu.cgi?dom=' + this.value;
    $('#content').fadeTo('fast', 0);
    $('.enscroll-track').fadeTo('fast', 0);
    $('.rotor').fadeIn('fast');
    $('#content').html('');
    var progress = 0;
    $.ajax({
        url: url,
        async: true,
        dataType: 'text',
    })
    .done(function(response) {
        $('#vserver-doms').html(response);
        /* Make domain selector cool */
        // $('#vserver-doms select').each(function(index, select) {
        //     var liveSearch = select.length > 8;
            // $(select).selectpicker({
            //     style: 'btn-default btn-sm',
            //     size: 8,
            //     liveSearch: liveSearch,
            //     actionsBox: true
            // });
        // });
        var liveSearch = $('#domain-selector')[0].length > 8;
        $('#domain-selector').selectpicker({
            style: 'btn-default btn-sm',
            size: 8,
            liveSearch: liveSearch,
            actionsBox: true
        });
        /* Also make dropdown toggle on hover */
        $('#vserver-doms [data-hover="dropdown"]').dropdownHover();
    })
    .always(function() {
        // $('#content').stop(true, true).scrollTop(0).fadeTo('fast', 1);
        // $('.enscroll-track').stop(true, true).scrollTop(0).fadeTo('fast', 1);
        // $('.rotor').fadeOut('fast');
        /* Navigate to domain edition form */
        var url = 'virtual-server/edit_domain.cgi?dom=' + that.value;
        $.ajax({
            url: url,
            async: true,
            dataType: 'text',
        })
        .done(function(response) {
            $('#content').html(response);
            updateContent(response, url);
        })
        .always(function(response) {
            $('#content').stop(true, true).scrollTop(0).fadeTo('fast', 1);
            $('.enscroll-track').stop(true, true).scrollTop(0).fadeTo('fast', 1);
            $('.rotor').fadeOut('fast');
        });
    });
});
