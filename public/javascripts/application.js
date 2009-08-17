/**
 * Completely clears a form.
 */
function clear_form(form) {
    form.getElements().each(function(el) {
        switch (el.type) {
            // Text fields
            case 'text':
                el.value= '';
                break;
            // Select dropdowns
            case 'select-one':
                el.options[0].selected= true;
                break;
        }
    });
}