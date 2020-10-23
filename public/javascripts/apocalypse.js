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

  $('#form #pickup-zip').on('change', function() {
    acceptedZipcodes = this.getAttribute('data-servicearea');

    if( this.value.length != 5 || !acceptedZipcodes.includes(this.value) ) {
      // TODO: log requested zip code with timestamp
      // TODO: should be a modal, alert is too harsh
      alert('Sorry, we can\'t pickup orders in '+ this.value);
    }
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
  // validate data
  for(key in data) {
    setElementValidity(document.getElementsByTagName('input'));
  }

  // serialize data
  var data = collectFormData();

  console.log(data);

  // submit request if all elements are valid
  if ( document.getElementsByClassName('error').length == 0 ) {
    $.ajax({
      url: "/apocalypse/request_pickup",
      method: "POST",
      data: data,
      dataType: "html",
      complete: function(xhr, textStatus) {
        if ( xhr.status == 201 ) {
          window.location = xhr.responseText
        } else {
          alert('uh-oh, something went wrong');
        }
      }
    });
  }
}

function collectFormData() {
  var pickupLocation = mapInputElements($('#pickup-location input'));
      invoiceLocation = mapInputElements($('#invoice-location input'));
      deliveryRequests = [];

  for (let i = 0; i < $('.delivery-request').length; i++) {
    var delivery = $('.delivery-request')[i];

    deliveryRequests.push({
      delivery_location: mapInputElements($(delivery).find('.delivery-location input')),
      available_from: getDatetimepickerValue($(delivery).find('.available-from')),
      notes: $(delivery).find('.delivery-notes textarea')[0].value,
      items: collectItems($(delivery).find('.items-wrapper .item'))
    })
  };

  console.log('delivery requests', deliveryRequests)

  return {
    pickup_location: pickupLocation,
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

  console.log('result', resultObject)

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

