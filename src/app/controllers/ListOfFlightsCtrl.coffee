qantasApp = angular.module 'qantasApp'

qantasApp.controller 'ListOfFlightsCtrl', ($http, auth, nav, storage) ->

    # static list of flights, remove once server returns all flights on day
    @flights = [
      {
        title: 'QF1234'
        leavingIn: 'Leaving in 20 mins'
      },
      {
        title: 'QF1235'
        leavingIn: 'Leaving in 20 mins'
      },
      {
        title: 'QF1236'
        leavingIn: 'Leaving in 20 mins'
      },
      {
        title: 'QF1237'
        leavingIn: 'Leaving in 20 mins'
      }
    ]

    return