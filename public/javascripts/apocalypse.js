$(document).ready(function() {
  // log the screen width on resize
  window.onresize = function(event) {
    console.log("window width: "+$(window).width()+"px");
  };

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
      alert('Sorry, we can\'t pickup orders in '+ this.value +' yet');
    }
  });
});

function addDroppoffRow() {
  // don't trigger validations
  event.preventDefault();

  var template = $('#form #dropoff-locations .dropoff-location').clone()
      freshRow = template[0];
      newLocationIndex = template.length;

  // add a template row
  $.each($(freshRow).find('input'), function(i, el) {
    // update location index on name field
    var name = el.attributes.name.value;
        locationIndex = name.charAt(name.length - 1)
        updated_name = name.replace(locationIndex, newLocationIndex);

    el.setAttribute('name', updated_name);

    // don't wipe the city value field cause only dropoffs in berlin are accepted
    if ( !el.classList.contains('dropoff-city') ) {
      el.value = ''
    };
  })

  $('#form #dropoff-locations .dropoff-location-rows').append(freshRow);

  // if the remove button is hidden, display it
  if ( $('#form #remove-last-location').hasClass('hidden') ) {
    $('#form #remove-last-location').removeClass('hidden');
  }
};

function removeLastDropoffRow() {
  // don't trigger validations
  event.preventDefault();

  // remove the last dropoff location
  $('#form #dropoff-locations .dropoff-location').last().remove();

  // hide the remove button if there's only one location in the list
  if ( $('#form #dropoff-locations .dropoff-location').length == 1 ) {
    $('#form #remove-last-location').addClass('hidden');
  };
};

function submitData() {
  // serialize data
  var fields = document.getElementsByTagName('input');
      data = mapInputElements(fields, {});

  // validate data
  for( key in data) {
    setElementValidity(document.getElementsByName(key)[0]);
  }

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

function mapInputElements(elements, resultObject) {
  for (let i = 0; i < elements.length; i++) {
    resultObject[elements[i].name] = elements[i].value;
  }

  return resultObject;
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

