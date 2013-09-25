$ ->
    initialize = ->
        mapOptions = 
          center: new google.maps.LatLng(37.7749300 , -122.4194200)
          zoom: 12
          mapTypeId: google.maps.MapTypeId.ROADMAP
        map = new google.maps.Map(document.getElementsByClassName("map-canvas")[0],mapOptions);

    initialize()