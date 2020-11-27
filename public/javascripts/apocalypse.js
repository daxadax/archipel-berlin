$(document).ready(function() {
  // log the screen width on resize
  window.onresize = function(event) {
    console.log("window width: "+$(window).width()+"px");
  };

  addDeliveryRequest();

  $('#form input').on('blur', function() {
    setElementValidity(this);
  });

  $('#form input').on('change', function() {
    setElementValidity(this);
  });


  // this is currently an a/b thing. when the old version goes away it doesn't
  // need to be 'new shit' anymore
  $("#new-shit #pickup-location select").on('change', function () {
    var selectedContact = $(this).val();
    var contactSelect = $("#new-shit #pickup-contact select");

    if ( selectedContact === '' ) { return }

    // get contacts for the selected location and populate select box
    $.ajax({
      cache: false,
      type: "GET",
      url: "/utils/contact_options_for_location",
      data: { "location_id": selectedContact },
      success: function (data) {
        contactSelect.html('');
        JSON.parse(data).forEach(function(option, index, array) {
          contactSelect.append($('<option></option>').val(option.id).html(option.name));
        });
      },
      error: function (xhr, ajaxOptions, thrownError) {
        alert('Failed to retrieve contacts.');
      }
    });
  });

  $("#new-shit .delivery-location select").on('change', function () {
    var selectedContact = $(this).val();

    if ( selectedContact === '00' ) {
      $(this.parentElement).siblings('.delivery-contact').addClass('hidden');
      $(this.parentElement).siblings('.add-delivery-location').removeClass('hidden');
      $(this.parentElement).siblings('.add-delivery-contact').removeClass('hidden');
      return
    } else {
      var contactSelect = $(this.parentElement.nextElementSibling).find('select');

      $(this.parentElement).siblings('.delivery-contact').removeClass('hidden');
      $(this.parentElement).siblings('.add-delivery-location').addClass('hidden');
      $(this.parentElement).siblings('.add-delivery-contact').addClass('hidden');

      // get contacts for the selected location and populate select box
      $.ajax({
        cache: false,
        type: "GET",
        url: "/utils/contact_options_for_location",
        data: { "location_id": selectedContact },
        success: function (data) {
          $(contactSelect).html('');
          JSON.parse(data).forEach(function(option, index, array) {
            $(contactSelect).append($('<option></option>').val(option.id).html(option.name));
          });
          contactSelect.append($('<option></option>').val('00').html('Add new contact'));
        },
        error: function (xhr, ajaxOptions, thrownError) {
          alert('Failed to retrieve contacts.');
        }
      });
    }
  });

  $("#new-shit .delivery-contact select").on('change', function () {
    var selectedContact = $(this).val();
        thisContactNode = $(this.parentNode.parentNode);

    if ( selectedContact === '00' ) {
      thisContactNode.siblings('.add-delivery-contact').removeClass('hidden');
    } else {
      thisContactNode.siblings('.add-delivery-contact').addClass('hidden');
    };
  });
});

function addItem(el) {
  // don't trigger validations
  event.preventDefault();

  var template = $('.row.item').clone()[0]

  el.closest('.row').previousElementSibling.append(template);
};

function addDeliveryRequest() {
  // don't trigger validations on click
  if ( event ) { event.preventDefault(); }

  if ( $('#form #deliveries').length == 0 ) { return }

  var template = $('#form #deliveries .delivery-request-template').clone()
      newDelivery = template[0];
      deliveryIndex = $('#delivers .delivery-request').length;

  $('#form #deliveries .delivery-requests').append(newDelivery);

  // set datetime picker options
  $(newDelivery).find('.available-from').datetimepicker({
    inline: true,
    defaultTime: '10:00'
  });

  newDelivery.classList.remove('hidden', 'delivery-request-template');
  newDelivery.classList.add('delivery-request');

  // if the remove button is hidden, display it
  if ( $('#form #remove-last-location').hasClass('hidden') ) {
    $('#form #remove-last-location').removeClass('hidden');
  }
};

function removeLastDeliveryRequest() {
  // don't trigger validations
  event.preventDefault();

  // remove the last dropoff location
  $('#form #deliveries .delivery-request').last().remove();

  // hide the remove button if there's only one location in the list
  if ( $('#form #deliveries .delivery-request').length <= 1 ) {
    $('#form #remove-last-location').addClass('hidden');
  };
};

function submitData() {
  event.preventDefault();

  // validate data
  for(key in data) {
    setElementValidity(document.getElementsByTagName('input'));
  }

  // serialize data
  var data = collectFormData();

  console.log(data);

  // return unless all elements are valid
  if ( document.getElementsByClassName('error').length > 0 ) { return }

  // submit request
  $.ajax({
    method: "POST",
    url: "/apocalypse/request_pickup",
    data: data,
    dataType: "text",
    complete: function(xhr, textStatus) {
      if ( xhr.status == 201 ) {
        window.location = xhr.responseText
      } else {
        alert('uh-oh, something went wrong');
      }
    }
  });
}

function collectFormData() {
  var pickupLocationInput = mapInputElements($('#pickup-location input'));
      pickupLocationSelect = mapInputElements($('#pickup-location select'));
      pickupContactInput = mapInputElements($('#pickup-contact input'));
      pickupContactSelect = mapInputElements($('#pickup-contact select'));
      invoiceLocation = mapInputElements($('#invoice-location input'));
      deliveryRequests = [];

  for (let i = 0; i < $('.delivery-request').length; i++) {
    var delivery = $('.delivery-request')[i];

    deliveryRequests.push({
      delivery_location_input: mapInputElements($(delivery).
        find('.add-delivery-location input')),
      delivery_location_select: mapInputElements($(delivery).
        find('.delivery-location select')),
      delivery_contact_input: mapInputElements($(delivery).
        find('.add-delivery-contact input')),
      delivery_contact_select: mapInputElements($(delivery).
        find('.delivery-contact select')),
      available_from: getDatetimepickerValue($(delivery).find('.available-from')),
      notes: $(delivery).find('.delivery-notes textarea')[0].value,
      items: collectItems($(delivery).find('.items-wrapper .item'))
    })
  };

  return {
    pickup_location_select: pickupLocationSelect,
    pickup_location: pickupLocationInput,
    pickup_contact_select: pickupContactSelect,
    pickup_contact: pickupContactInput,
    invoice_location: invoiceLocation,
    deliveries: deliveryRequests
  }
}

function collectItems(elements) {
  var items = []

  for (let i = 0; i < elements.length; i++) {
    items.push(mapInputElements($(elements[i]).find('input')));
  };

  return items;
}

function mapInputElements(elements) {
  var resultObject = {};

  for (let i = 0; i < elements.length; i++) {
    resultObject[elements[i].name] = elements[i].value;
  }

  return resultObject;
}

function getDatetimepickerValue(element) {
  return element.datetimepicker('getValue');
}

function setElementValidity(element) {
  var msgWrapper = $(element).parent().find('.validation-msg');
      result = checkValidity(element);

  if ( result.status == 'invalid' ) {

    // add invalid class
    element.classList.add('error');

    // show validation message
    msgWrapper.html(result.message);
    msgWrapper.removeClass('hidden');
  } else {
    // remove invalid class if exists
    element.classList.remove('error');

    // hide validation message
    msgWrapper.addClass('hidden');
  }
};

function checkValidity(element) {
  // default rule
  if ( element.required && emptyValue(element.value) ) {
    return { status: 'invalid', message: 'This field is required' }
  }

  // validate pickup weight
  if ( element.id == 'pickup-weight' && element.value == 0 ) {
    return {
      status: 'invalid',
      message: 'Please give an estimate of the total weight in kg'
    }
  }

  // TODO: validate telephone numbers
  // TODO: validate email


  return { status: 'valid' }
}

function emptyValue(value) {
  return (value === "" || value === null || value === undefined)
}

