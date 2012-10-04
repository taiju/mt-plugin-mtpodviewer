$(function() {
    $('#search-text').focus();
    var data_source = $('#search-text').data('source');
    $('#search-btn').on('click', function(e) {
        var key = $('#search-text').val();
        var $pod_contents = $('#pod-contents');
        if ($.inArray(key, data_source)) {
            $pod_contents
                .fadeOut('fast', function() {
                    $(this).html('<div class="well">wait</div>')
                           .fadeIn('slow');
                    setInterval(function() {
                        var html = $('#pod-contents .well').html();
                        $('#pod-contents .well').html(html + '.');
                    }, 800);
                });
            $.get(
                script_path,
                { __mode: 'partial_text', key: key },
                function(text) {
                    $pod_contents
                        .fadeOut('fast', function() {
                            $(this).html(text)
                                   .fadeIn('slow');
                        });
                },
                'text'
            );
        }
        return false;
    });
});
