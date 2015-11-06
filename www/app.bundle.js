(function() {
  var qantasApp;

  window.isCordova = window.hasOwnProperty('cordova');

  qantasApp = angular.module('qantasApp', ['onsen', 'ngResource', 'ipCookie', 'ngAnimate', 'angularFileUpload', 'geolocation', 'ngMap']);

  qantasApp.run(function() {
    return document.addEventListener('deviceready', function() {
      if ('addEventListener' in document) {
        return document.addEventListener('DOMContentLoaded', (function() {
          FastClick.attach(document.body);
        }), false);
      }
    });
  });

  qantasApp.run(function() {
    var func;
    func = function(ev) {
      if (window.scrollY > 0) {
        return document.activeElement.blur();
      }
    };
    return window.ontouchmove = _.throttle(func, 100, true);
  });

  qantasApp.run(function($q, $timeout) {
    var dfd;
    dfd = $q.defer();
    window.$deviceReady = dfd.promise;
    if (window.navigator.userAgent.match(/iPhone|iPad|iPod/)) {
      window.platform = 'webiOS';
    } else if (window.navigator.userAgent.match(/android|Android/)) {
      window.platform = 'webAndroid';
    } else {
      window.platform = 'other';
    }
    return document.addEventListener('deviceready', (function() {
      window.isNativeAndroid = window.isCordova && (window.device.platform.toLowerCase() === 'android');
      window.isNativeiOS = window.isCordova && (window.device.platform.toLowerCase() === 'ios');
      window.isNativeiOSEmulator = window.device.model === 'x86_64';
      if (window.isNativeAndroid) {
        window.platform = 'nativeAndroid';
      } else if (window.isNativeiOS) {
        window.platform = 'nativeiOS';
      } else {
        window.platform = 'nativeOther';
      }
      if (window.cordova.getAppVersion != null) {
        return window.cordova.getAppVersion(function(version) {
          window.qantasAppVersion = version;
          return dfd.resolve();
        });
      } else {
        return dfd.resolve();
      }
    }));
  });

  qantasApp.run(function($rootScope, $timeout, DialogView, IOSAlertDialogAnimator, prefs, analyticsSetup, templatePrefetch) {
    window.jQuery('.hide-on-first-load').css({
      visibility: 'visible'
    });
    DialogView.registerAnimator('iosAlertStyle', new IOSAlertDialogAnimator());
    $rootScope.$on('login', prefs.$fetch);
    return $timeout(templatePrefetch.run, 1000, false);
  });

  qantasApp.run(function($rootScope, localNotifications) {
    $rootScope.isCordova = window.isCordova;
    $rootScope.isNativeAndroid = window.isNativeAndroid;
    $rootScope.isNativeiOSEmulator = window.isNativeiOSEmulator;
    return document.addEventListener('deviceready', function() {
      if (!window.cordova.plugins.notification.badge) {
        return;
      }
      window.cordova.plugins.notification.badge.hasPermission(function(granted) {
        if (!granted) {
          return;
        }
        return window.cordova.plugins.notification.badge.configure({
          autoClear: true
        });
      });
      $rootScope.$on('login', function() {
        return localNotifications.syncOnShiftChanges();
      });
      return $rootScope.$on('logout', function() {
        return localNotifications.clearAll();
      });
    });
  });

  qantasApp.run(function($rootScope, $location, $timeout, auth, nav) {
    $rootScope.nav = nav;
    $rootScope.auth = auth;
    return ons.ready(function() {
      auth.start();
      if (auth.isAuthenticated()) {
        nav.setRootPage('navigator');
      } else {
        nav.setRootPage('authCtrl');
      }
      return $rootScope.$on('logout', function(ev, currentUser) {
        return nav.setRootPage('authCtrl');
      });
    });
  });

}).call(this);

(function() {
  var qantasApp,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('transform', function($rootScope) {
    return {
      response: function(key, opts) {
        if (opts == null) {
          opts = {};
        }
        return function(raw) {
          if (opts.broadcast) {
            $rootScope.$broadcast(opts.broadcast);
          }
          if (_.isNull(key)) {
            return null;
          } else {
            return angular.fromJson(raw)[key];
          }
        };
      }
    };
  });

  qantasApp.filter('ordinal', function() {
    return function(input) {
      var ordinals, v;
      if (!input) {
        return '';
      }
      if (typeof input === 'object') {
        input = input.getDate();
      } else if (indexOf.call(input, ':') >= 0) {
        input = (new Date(input)).getDate();
      }
      ordinals = ['th', 'st', 'nd', 'rd'];
      v = parseInt(input) % 100;
      return ordinals[(v - 20) % 10] || ordinals[v] || ordinals[0];
    };
  });

  qantasApp.service('errorList', function() {
    return function(err) {
      return _.map(err.details, function(fieldError) {
        return fieldError.msg;
      });
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.controller('AuthCtrl', function($rootScope, $scope, auth, errorList, pg, nav) {
    var inProgress, lolHandleErrors;
    inProgress = false;
    ons.ready(function() {
      return $rootScope.slidingMenu.setSwipeable(false);
    });
    if (auth.isAuthenticated()) {
      nav.setRootPage('navigator');
    }
    lolHandleErrors = function(err) {
      var error, message, messages, title;
      error = (err != null ? err.data : void 0) || {};
      title = 'Oops';
      messages = ['Unknown error occured - Please try again later.'];
      switch (error.error) {
        case 'ValidationFailed':
          title = 'Could not register';
          messages = errorList(error);
          break;
        case 'AuthFailed':
          title = 'Could not log in';
          messages = errorList(error);
          break;
        default:
          if (error.message) {
            messages = [error.message];
          }
      }
      message = messages.join('\n');
      return pg.alert({
        title: title,
        msg: message
      });
    };
    this.loginSubmit = (function(_this) {
      return function() {
        var credentials;
        if (inProgress) {
          return;
        }
        inProgress = true;
        _this.errors = null;
        credentials = {
          email: _this.email,
          password: _this.password
        };
        window.loginUserModal.show();
        return auth.login(credentials).then(function(user) {
          setTimeout((function() {
            return analytics.track('App Login');
          }), 1000);
          return nav.setRootPage('navigator');
        })["finally"](function() {
          inProgress = false;
          return window.loginUserModal.hide();
        })["catch"](lolHandleErrors);
      };
    })(this);
    this.registerSubmit = (function(_this) {
      return function() {
        var credentials;
        if (inProgress) {
          return;
        }
        inProgress = true;
        credentials = {
          email: _this.email,
          displayName: _this.displayName,
          password: _this.password
        };
        window.registerUserModal.show();
        return auth.register(credentials).then(function(data) {
          return auth.login(credentials);
        }).then(function(user) {
          setTimeout((function() {
            return analytics.track('App Register');
          }), 1000);
          $rootScope.$broadcast('register');
          return nav.setRootPage('navigator');
        })["finally"](function() {
          inProgress = false;
          return window.registerUserModal.hide();
        })["catch"](lolHandleErrors);
      };
    })(this);
    this.auth = auth;
    this.nav = nav;
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.controller('ContactCtrl', function($scope, auth, nav) {
    this.contact = function() {
      return console.log('getting in contacts');
    };
  });

}).call(this);

(function() {
  var _pluralize, createDateObject, getLastNItems, hasShift, isSameDay, makeDay, makeHour, makeHourFromDate, makeSchedule, qantasApp, setDayValidity, setTimeForDateObject;

  qantasApp = angular.module('qantasApp');

  makeDay = function(dayNumber, lol, lol2, absDate, day) {
    if (!day) {
      day = new Date;
      day.setSeconds(0);
      day.setMilliseconds(0);
      if (absDate == null) {
        absDate = day.getDate() + dayNumber;
      }
      day.setDate(absDate);
    }
    return {
      day: day,
      start: {
        keys: [],
        period: 'am'
      },
      end: {
        keys: [],
        period: 'pm'
      }
    };
  };

  makeHourFromDate = function(date) {
    var hours, keys, minLength, minutes, padding, period, toPad;
    hours = date.getHours();
    period = 'am';
    if (hours >= 12) {
      period = 'pm';
    }
    if (hours > 12) {
      hours = hours - 12;
    }
    minutes = date.getMinutes().toString();
    minLength = 2;
    if (minutes.length < minLength) {
      toPad = minLength - minutes.length;
      padding = Array(toPad + 1).join('0');
      minutes = padding + minutes;
    }
    keys = (hours.toString() + minutes).split('');
    return {
      keys: keys,
      period: period
    };
  };

  makeSchedule = function(days) {
    var i, results;
    return (function() {
      results = [];
      for (var i = 0; 0 <= days ? i < days : i > days; 0 <= days ? i++ : i--){ results.push(i); }
      return results;
    }).apply(this).map(makeDay);
  };

  makeHour = function(hour, period) {
    var parsedHour;
    parsedHour = parseInt(hour) || 0;
    if (parsedHour === 12 && period === 'am') {
      parsedHour = 0;
    } else if (parsedHour === 12 && period === 'pm') {
      parsedHour = 12;
    } else {
      if (period === 'pm') {
        parsedHour += 12;
      }
    }
    return parsedHour;
  };

  setTimeForDateObject = function(date, timeObj) {
    var hours, keys, minutes;
    keys = timeObj.keys.slice();
    minutes = keys.slice(keys.length - 2).join('');
    hours = keys.slice(0, keys.length - 2).join('') || '0';
    date.setHours(makeHour(hours, timeObj.period));
    date.setMinutes(parseInt(minutes) || 0);
    return date;
  };

  setDayValidity = function(day) {
    var hours, i, isValid, keys, len, minutes, time, timeKey, times;
    if (!hasShift(day)) {
      day.isValid = void 0;
      return void 0;
    }
    times = ['start', 'end'];
    isValid = true;
    for (i = 0, len = times.length; i < len; i++) {
      timeKey = times[i];
      time = day[timeKey];
      keys = time.keys;
      hours = keys.slice(0, keys.length - 2).join('') || '0';
      minutes = keys.slice(keys.length - 2).join('');
      if ((hours > 12) || (minutes >= 60)) {
        time.isValid = false;
        if (isValid) {
          isValid = false;
        }
      } else {
        time.isValid = true;
      }
    }
    day.isValid = isValid;
    return isValid;
  };

  getLastNItems = function(arr, n) {
    return arr.slice(Math.max(arr.length - n, 1));
  };

  createDateObject = function(day) {
    var end, start;
    setDayValidity(day);
    start = new Date(day.day);
    end = new Date(day.day);
    setTimeForDateObject(start, day.start);
    setTimeForDateObject(end, day.end);
    if (start.getTime() > end.getTime()) {
      end.setDate(end.getDate() + 1);
    }
    return {
      start: start,
      end: end,
      id: day.id
    };
  };

  isSameDay = function(date1, date2) {
    return date1.getDate() === date2.getDate() && date1.getMonth() === date2.getMonth() && date1.getFullYear() === date2.getFullYear();
  };

  hasShift = function(day) {
    return day.start.keys.length && day.end.keys.length;
  };

  _pluralize = function(num, string, suffix) {
    var output;
    if (suffix == null) {
      suffix = 's';
    }
    output = num + " " + string;
    if (num !== 1) {
      output += suffix;
    }
    return output;
  };

  qantasApp.controller('DateOfFlightCtrl', function($rootScope, $http, auth, nav, prefs, storage) {
    var HEXES, addPeriod, day, field, handleDigitPressed, i, len, ref, selectNextPeriod;
    this.selectDay = (function(_this) {
      return function(index) {
        _this.selectedDayIndex = index;
        _this.selectedDay = _this.schedule[index];
        _this.selectedField = 'start';
        return _this.justChangedField = true;
      };
    })(this);
    this.selectShiftField = (function(_this) {
      return function(field) {
        _this.selectedField = field;
        return _this.justChangedField = true;
      };
    })(this);
    this.incrementSelectedDay = (function(_this) {
      return function() {
        var lastDay, newDay, newDayIndex;
        newDayIndex = _this.selectedDayIndex + 1;
        if (!_this.schedule[newDayIndex]) {
          lastDay = _this.schedule[_this.schedule.length - 1];
          newDay = new Date(lastDay.day);
          newDay.setDate(newDay.getDate() + 1);
          _this.schedule.push(makeDay(null, null, null, null, newDay));
        }
        return _this.selectDay(newDayIndex);
      };
    })(this);
    handleDigitPressed = (function(_this) {
      return function(key, willResetTime) {
        var field, ref;
        field = _this.selectedDay[_this.selectedField];
        if (willResetTime) {
          return field.keys = [key];
        } else if (((ref = field.keys) != null ? ref.length : void 0) < 4) {
          return field.keys.push(key);
        } else {
          selectNextPeriod();
          return handleDigitPressed(key);
        }
      };
    })(this);
    selectNextPeriod = (function(_this) {
      return function() {
        if (_this.selectedField === 'start') {
          return _this.selectShiftField('end');
        } else {
          return _this.incrementSelectedDay();
        }
      };
    })(this);
    addPeriod = (function(_this) {
      return function(period) {
        var field, paddBy, targetLength;
        field = _this.selectedDay[_this.selectedField];
        field.period = period;
        targetLength = 3;
        paddBy = 0;
        if (field.keys.length < targetLength) {
          field.keys = field.keys.concat(['0', '0']);
        }
        return selectNextPeriod();
      };
    })(this);
    this.keypadClick = (function(_this) {
      return function(key) {
        var field;
        field = _this.selectedDay[_this.selectedField];
        _this.willResetTime = _this.justChangedField;
        _this.justChangedField = false;
        switch (key) {
          case 'next':
            _this.incrementSelectedDay();
            break;
          case 'am':
          case 'pm':
            addPeriod(key);
            break;
          case 'clear':
            field.keys = [];
            field.isValid = void 0;
            field.period = _this.selectedField === 'start' ? 'am' : 'pm';
            break;
          default:
            handleDigitPressed(key, _this.willResetTime);
        }
        return setDayValidity(_this.selectedDay);
      };
    })(this);
    this.exit = function() {
      var _close, numOfShfits;
      numOfShfits = this.numberOfShifts();
      _close = function() {
        var eventName;
        eventName = this.shiftToEdit != null ? 'Edit' : 'Add';
        return nav.back();
      };
      if (!(numOfShfits > 0)) {
        _close();
        return;
      }
      return pg.confirm({
        title: 'You have unsaved shifts',
        msg: 'Are you sure you want to leave?',
        buttons: {
          'Yes': _close,
          'Cancel': function() {}
        }
      });
    };
    this.printDuration = function(day) {
      var dur, end, join, last, output, outputString, ref, start;
      if (!hasShift(day)) {
        return;
      }
      ref = createDateObject(day), start = ref.start, end = ref.end;
      start = moment(start);
      end = moment(end);
      dur = moment.duration(end.diff(start))._data;
      output = [];
      if (dur.hours) {
        output.push(_pluralize(dur.hours, 'hour'));
      }
      if (dur.minutes) {
        output.push(_pluralize(dur.minutes, 'minute'));
      }
      join = ', ';
      if (output.length > 1) {
        last = output.length - 1;
        output[last] = '##' + output[last];
      }
      outputString = output.join(join);
      outputString = outputString.replace(join + '##', ' and ');
      return outputString;
    };
    this.saveShifts = function() {
      var day, eventName, i, len, ref, shiftsToSave;
      ref = this.schedule;
      for (i = 0, len = ref.length; i < len; i++) {
        day = ref[i];
        if (hasShift(day)) {
          if (!((day.isValid === true) || (day.start.isValid === true) || (day.end.isValid === true))) {
            pg.alert({
              msg: 'Please fix invalid shifts. Days must have valid 12 hour times.',
              title: 'Invalid Shifts'
            });
            return;
          }
        }
      }
      window.addShiftsModal.show();
      shiftsToSave = this.schedule.filter(hasShift).map(createDateObject);
      return eventName = this.shiftToEdit != null ? 'Edit' : 'Add';
    };
    this.moveToNext = function() {
      nav.goto('rideCountCtrl');
      console.log('date of flight', this.date);
      return storage.set('dateOfFlight', this.date);
    };
    this.back = function() {
      return nav.resetTo('flightNumberCtrl');
    };
    HEXES = ['#8A8B47', '#478B81', '#8B477F', '#8B4747'];
    this.HEX = HEXES[Math.round(Math.random() * (HEXES.length - 1))];
    this.isEditing = false;
    if (this.shiftToEdit != null) {
      this.isEditing = true;
      this.shiftToEdit = JSON.parse(JSON.stringify(this.shiftToEdit));
      ref = ['start', 'end'];
      for (i = 0, len = ref.length; i < len; i++) {
        field = ref[i];
        this.shiftToEdit[field] = new Date(this.shiftToEdit[field]);
      }
      day = new Date(this.shiftToEdit.start);
      day.setHours(0);
      day.setSeconds(0);
      day.setMilliseconds(0);
      this.schedule = [
        {
          day: day,
          start: makeHourFromDate(this.shiftToEdit.start),
          end: makeHourFromDate(this.shiftToEdit.end),
          id: this.shiftToEdit.id
        }
      ];
      setDayValidity(this.schedule[0]);
    } else {
      this.schedule = makeSchedule(60);
    }
    this.selectDay(0);
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.controller('EditProfileCtrl', function($rootScope, $scope, auth, nav, UserResource, prefs, phoneValidation) {
    var displayNameHasChanged, profileId;
    profileId = nav.getParams('profileId');
    displayNameHasChanged = false;
    this.selectedCountry = phoneValidation.selectedCountry;
    this.user = UserResource.get({
      id: profileId
    });
    this.isValidNumber = false;
    window.editProfile = this;
    $scope.$watch('eprf.user.displayName', function(newValue, oldValue) {
      if ((newValue && oldValue) && (newValue !== oldValue)) {
        return displayNameHasChanged = true;
      }
    });
    this.checkNumber = function() {
      this.isValidNumber = phoneValidation.isNumberValid(this.user.phone);
      this.user.phone = phoneValidation.formatPhoneNumber(this.user.phone);
      return phoneValidation.selectedCountry.phoneNumber = this.user.phone;
    };
    this.submitUser = function() {
      window.editProfileModal.show();
      if (this.user.defaultDisplayNameSet && displayNameHasChanged) {
        auth.currentUser.defaultDisplayNameSet = false;
        this.user.defaultDisplayNameSet = false;
        this.user.changedDisplayName = true;
      }
      return this.user.$update({
        id: profileId
      }).then(function() {
        return nav.back();
      })["catch"](function() {
        return alert('An error has occured');
      })["finally"](function() {
        return window.editProfileModal.hide();
      });
    };
    phoneValidation.setup();
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.controller('FlightNumberCtrl', function($http, auth, nav, storage) {
    var hideKeyboard;
    hideKeyboard = function() {
      document.activeElement.blur();
      return Array.prototype.forEach.call(document.querySelectorAll('input, textarea'), function(it) {
        return it.blur();
      });
    };
    this.submitFlightNumber = function() {
      this.finalFlightNumber = 'QF' + this.flightNumber;
      storage.set('flightNumber', this.finalFlightNumber);
      return nav.goto('dateOfFlightCtrl');
    };
    this.clear = function() {
      this.flightNumber = null;
      return nav.resetTo('flightNumberCtrl');
    };
    hideKeyboard();
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.controller('FlightSummaryCtrl', function($http, auth, nav, storage) {
    var prepareFlightInfo;
    this.flightNumber = storage.get('flightNumber');
    this.flightDate = storage.get('flightDate');
    this.latLong = {
      location: {
        latitude: 45,
        longitude: -73
      }
    };
    console.log('flightNumber', this.flightNumber);
    console.log('flightDate', this.flightDate);
    console.log('latLong', this.latLong);
    prepareFlightInfo = function() {
      var flightInfo;
      return flightInfo = [];
    };
    this.findRide = function() {
      return nav.goto('mapCtrl');
    };
    prepareFlightInfo();
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.controller('HowToCtrl', function($scope, auth, launchAddShiftsHelper, nav, pg, prefs) {
    this.cancelOnboarding = function() {
      if (!prefs.completedOnboarding) {
        nav.back();
        return pg.alert({
          title: 'Did you know?',
          msg: 'You can always find this in Profile > Settings'
        });
      } else {
        return nav.back();
      }
    };
    this.completedOnboarding = function() {
      var _getStarted;
      _getStarted = function() {
        return pg.confirm({
          title: 'Ready to get started?',
          buttons: {
            'Yes please!': launchAddShiftsHelper,
            'Not now': function() {}
          }
        });
      };
      if (!prefs.completedOnboarding) {
        nav.back();
        return _getStarted();
      } else {
        return nav.back();
      }
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.controller('MapCtrl', function($scope, auth, nav) {
    var defaultMapType, fallBackLocation, intialZoomLevel;
    intialZoomLevel = 8;
    fallBackLocation = '-33.8909257, 151.1959506';
    defaultMapType = google.maps.MapTypeId.TERRAIN;
    $scope.googleMap = {
      zoom: intialZoomLevel,
      center: fallBackLocation,
      options: {
        mapTypeId: defaultMapType,
        streetViewControl: false,
        panControl: false,
        disableDefaultUI: true,
        zoomControl: true,
        disableDoubleClickZoom: true,
        minZoom: 0
      },
      control: {}
    };
    this.updateCurrentLocation = function() {
      return console.log('getting users current location');
    };
    this.proceed = function() {
      return nav.goto('contactCtrl');
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.controller('ResetPasswordCtrl', function($http, $rootScope, $scope, pg, nav) {
    this.resetPass = function() {
      return $http.post(config.apiBase + "/v1/requestPasswordReset", {
        email: this.email
      }).then(function() {
        return pg.alert({
          msg: 'You will be sent an email with instructions on how to reset your password.',
          title: 'Password Reset'
        });
      })["catch"](function(err) {
        return pg.alert({
          msg: 'An error occured'
        });
      })["finally"](function() {
        return nav.setRootPage('authCtrl');
      });
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.controller('RideCountCtrl', function($http, auth, nav, storage) {
    var jqLite;
    jqLite = angular.element;
    this.submitValue = function(value) {
      this.value = value;
      $('.buttonOne').addClass('animated bounceOutLeft');
      $('.buttonTwo').addClass('animated bounceOutRight');
      $('.textOne').addClass('animated bounceOutRight');
      return setTimeout((function() {
        return $('.removeElement').hide();
      }), 300);
    };
    this.submitCount = function() {
      console.log('submitting ride count number to API', this.value);
      storage.set('rideCount', this.value);
      return nav.goto('flightSummaryCtrl');
    };
    this.clearValue = function() {
      this.value = null;
      return nav.resetTo('rideCountCtrl');
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.controller('SearchCtrl', function($http, auth, nav, focus, $timeout, SearchResource, pg, contactSearch, ContactFindResource) {
    var _actuallylaunchContactPicker, profileId;
    profileId = nav.getParams('profileId');
    this.focus = focus;
    this.hasSearched = false;
    $timeout((function() {
      return focus('searchInput');
    }), 50);
    this.searchUser = function() {
      this.isSearching = true;
      this.hasSearched = false;
      this.results = [];
      return SearchResource.searchUsers({
        q: this.searchTerm
      }).$promise.then((function(_this) {
        return function(results) {
          _this.results = results;
          _this.isSearching = false;
          return _this.hasSearched = true;
        };
      })(this));
    };
    this.cancelSearch = function() {
      this.searchTerm = null;
      this.results = [];
      return blur();
    };
    this.launchContactPicker = function() {
      return pg.confirm({
        title: 'Contact search',
        msg: 'Want to find people on Atum using your contact list?',
        buttons: {
          'Yes': _actuallylaunchContactPicker,
          'Cancel': function() {}
        }
      });
    };
    _actuallylaunchContactPicker = function() {
      window.findContactsModal.show();
      return contactSearch.queryContacts().then(function(contactsEmails) {
        return $http.post(config.apiBase + "/v1/contacts/find", JSON.stringify({
          emails: contactsEmails
        })).success(function(data, status, headers, config) {
          window.findContactsModal.hide();
          return nav.goto('listContactsCtrl', {
            contacts: data.users
          });
        }).error(function(data, status, headers, config) {});
      }).then(function(resp) {});
    };
    this.launchContacts = function() {
      return nav.goto('connectContactsCtrl');
    };
    this.inviteFriends = function() {
      var link, msg;
      if (window.isNativeAndroid) {
        msg = auth.currentUser.displayName + ' invited you to join Atum. Download the app from the Play Store.';
        link = config.androidStoreURL;
      } else {
        msg = auth.currentUser.displayName + ' invited you to join Atum. Download the app from the App Store.';
        link = config.appleStoreURL;
      }
      return pg.openShareSheet({
        msg: msg,
        link: link
      });
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.controller('SidemenuCtrl', function($scope, $http, $window, nav, pg, auth) {
    this.logout = function() {
      nav.resetTo('flightNumberCtrl');
      return auth.logout();
    };
    this.shareSheet = function() {
      var link, msg;
      if (window.isNativeAndroid) {
        msg = auth.currentUser.displayName + ' invited you to join Atum. Download the app from the Play Store.';
        link = config.androidStoreURL;
      } else if (window.isNativeiOS) {
        msg = auth.currentUser.displayName + ' invited you to join Atum. Download the app from the App Store.';
        link = config.appleStoreURL;
      } else {
        console.error('This is not supported on web');
      }
      if (window.isNativeAndroid || window.isNativeiOS) {
        return pg.openShareSheet({
          msg: msg,
          link: link
        });
      }
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.controller('UpdatePasswordCtrl', function($scope, $http, auth, pg, nav, UserResource) {
    var profileId;
    profileId = auth.currentUser.id;
    this.updatePass = function() {
      if (this.newPassword !== this.newPassword2) {
        pg.alert({
          msg: 'The passwords do not match, please try again.'
        });
        return;
      }
      return $http.post(config.apiBase + "/v1/users/" + profileId + "/changePassword", {
        oldPassword: this.oldPassword,
        newPassword: this.newPassword
      }).then(function(resp) {
        return pg.alert({
          msg: 'Your password has been reset.',
          title: 'Password Update'
        });
      }).then(function() {
        return nav.back('profileCtrl');
      })["catch"](function(err) {
        return pg.alert({
          msg: 'The password you provided was incorrect',
          err: err,
          title: 'Wrong password'
        });
      });
    };
  });

}).call(this);

(function() {
  var formatWithHTML, qantasApp, segment;

  qantasApp = angular.module('qantasApp');

  segment = function(time, insertEvery) {
    var index, newTime;
    if (insertEvery == null) {
      insertEvery = 2;
    }
    time = time.split('').reverse().join('');
    index = time.length - 1;
    newTime = '';
    while (index >= 0) {
      newTime += time[index];
      if (index % insertEvery === 0) {
        newTime += ':';
      }
      index -= 1;
    }
    return newTime.slice(0, -1);
  };

  formatWithHTML = function(time, before, after) {
    var char, i, j, keepWrapping, newTime, ref;
    if (before == null) {
      before = '<span class="text-muted">';
    }
    if (after == null) {
      after = '</span>';
    }
    time = time.split('');
    newTime = [];
    keepWrapping = true;
    for (i = j = 0, ref = time.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
      char = time.shift();
      if ((char === '0' || char === ':') && keepWrapping) {
        newTime.push("" + before + char + after);
      } else {
        newTime.push(char);
        keepWrapping = false;
      }
    }
    return newTime.join('');
  };

  qantasApp.directive('addTime', function($sce) {
    return {
      restrict: 'A',
      replace: true,
      templateUrl: 'templates/directives/addTime.html',
      scope: {
        time: '=addTime'
      },
      link: function(scope) {
        var _onTimeChange, targetLength;
        targetLength = 4;
        _onTimeChange = function(day) {
          var displayValue, padding, remaining, value;
          if (day == null) {
            day = {
              keys: []
            };
          }
          remaining = Math.max(targetLength - day.keys.length, 0);
          padding = (new Array(remaining + 1)).join('0');
          value = day.keys.join('');
          displayValue = segment(padding + value);
          return scope.displayHtml = $sce.trustAsHtml(formatWithHTML(displayValue));
        };
        return scope.$watch('time', _onTimeChange, true);
      }
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.directive('shiftsDuration', function($timeout, duration) {
    return {
      restrict: 'EA',
      scope: {
        start: '=',
        end: '='
      },
      link: function(scope, element) {
        var _repaintHack, _updateDuration, defer, ele;
        ele = element[0];
        defer = function(func) {
          return $timeout(func, 10);
        };
        _repaintHack = function() {
          ele.style.display = 'none';
          ele.offsetHeight;
          return ele.style.display = '';
        };
        _updateDuration = function(plzNo) {
          var dur;
          if (plzNo == null) {
            plzNo = true;
          }
          dur = duration(scope.start, scope.end);
          if (plzNo) {
            element.text(dur);
          }
          return $timeout(_repaintHack, 150);
        };
        scope.$watch('start', _updateDuration);
        return scope.$watch('end', _updateDuration);
      }
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.directive('textInput', function() {
    return {
      restrict: 'C',
      link: function(scope, element) {
        var _do;
        _do = function(arg) {
          var target;
          target = arg.target;
          if (target.value.length) {
            return target.classList.add('ng-has-text');
          } else {
            return target.classList.remove('ng-has-text');
          }
        };
        element.on('keyup', _do);
        return scope.$on('$destroy', function() {
          return element.off('keyup', _do);
        });
      }
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.directive('shiftsNextShift', function($interval, selectNextShift) {
    return {
      restrict: 'EA',
      replace: true,
      templateUrl: 'templates/directives/nextShift.html',
      scope: {
        feed: '=',
        showEmpty: '='
      },
      link: function(scope) {
        var interval, updateInterval, updateNow;
        updateNow = function() {
          return scope.now = new Date();
        };
        updateInterval = 5;
        interval = $interval(updateNow, updateInterval * 1000);
        updateNow();
        scope.$watch('feed', function() {
          var ref, shift, shiftIsCurrent;
          if (!scope.feed) {
            return;
          }
          ref = selectNextShift(scope.feed), shift = ref.shift, shiftIsCurrent = ref.shiftIsCurrent;
          scope.shift = shift;
          scope.shiftIsCurrent = shiftIsCurrent;
          return scope.now = new Date();
        });
        scope.$on('$destroy', function() {
          return $interval.cancel(interval);
        });
      }
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.directive('shiftsShiftList', function($rootScope, auth, nav) {
    return {
      restrict: 'EA',
      replace: true,
      templateUrl: 'templates/directives/shiftList.html',
      scope: {
        shifts: '=',
        feed: '='
      },
      link: function(scope, ele, attrs) {
        var _onFeedUpdate, _onShiftUpdate, globalShowCoworkers;
        _onShiftUpdate = function(shifts) {
          _.each(shifts, function(shift) {
            var ref;
            return shift.showCoworkers = globalShowCoworkers && ((ref = shift.coworkers) != null ? ref.length : void 0) > 0;
          });
          scope.schedule = _.chain(shifts).groupBy(function(shift) {
            var day, dayOfWeek;
            day = new Date(shift.start);
            dayOfWeek = day.getDay();
            day.setDate(day.getDate() - dayOfWeek);
            return day.toDateString();
          }).pairs().sortBy(function(arg) {
            var _startOfWeek, shifts, startOfWeek;
            _startOfWeek = arg[0], shifts = arg[1];
            startOfWeek = _startOfWeek.split(' ').slice(1).join(' ');
            return moment(startOfWeek, 'MMMM DD YYYY');
          }).map(function(arg) {
            var shifts, startOfWeek;
            startOfWeek = arg[0], shifts = arg[1];
            return {
              startOfWeek: startOfWeek,
              shifts: shifts
            };
          }).each(function(week) {
            var dur, i, len, results, shift, startOfWeek;
            startOfWeek = week.startOfWeek, shifts = week.shifts;
            week.hoursWorked = 0;
            results = [];
            for (i = 0, len = shifts.length; i < len; i++) {
              shift = shifts[i];
              if (shift.isDayOff) {
                continue;
              }
              dur = new Date(shift.end) - new Date(shift.start);
              results.push(week.hoursWorked += dur);
            }
            return results;
          }).value();
          return window.schedule = scope.schedule;
        };
        _onFeedUpdate = function(feed) {
          return scope.schedule = feed;
        };
        globalShowCoworkers = false;
        $rootScope.gotoShift = function(shift) {
          var connectionView, dayOff, feedView, profileView, view;
          view = ons.navigator.pages[0].name;
          dayOff = shift.isDayOff;
          profileView = 'templates/profileCtrl.html';
          connectionView = 'templates/connectionCtrl.html';
          feedView = 'templates/flightNumberCtrl.html';
          if (!dayOff && shift.ownerID === auth.currentUser.id) {
            return nav.goto('shiftViewCtrl', {
              shift: shift
            });
          } else if ((dayOff && view === profileView) || (dayOff && view === connectionView)) {
            return console.log('noView');
          } else if (dayOff && view === feedView) {
            return nav.goto('dayOffViewCtrl', {
              shift: shift
            });
          }
        };
        scope.$watch(attrs.showCoworkers, function(newValue) {
          globalShowCoworkers = attrs.hasOwnProperty('showCoworkers');
          return scope.showCoworkers = globalShowCoworkers;
        });
        if (_.has(attrs, 'feed')) {
          scope.$watch('feed', _onFeedUpdate);
        }
        if (_.has(attrs, 'shifts')) {
          scope.$watch('shifts', _onShiftUpdate);
        }
      }
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.directive('shiftsFocusOn', function() {
    return {
      link: function(scope, ele, attr) {
        return scope.$on('focusOn', function(e, name) {
          if (name === attr.shiftsFocusOn) {
            return ele[0].focus();
          }
        });
      }
    };
  });

  qantasApp.factory('focus', function($rootScope, $timeout) {
    return function(name) {
      return $timeout(function() {
        return $rootScope.$broadcast('focusOn', name);
      });
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.directive('shiftsLeftButton', function($rootScope, $timeout, nav) {
    return {
      restrict: 'AE',
      templateUrl: 'templates/directives/shiftsLeftButton.html',
      link: function(scope) {
        var _do;
        scope.pendingConnections = $rootScope.pendingConnections;
        $rootScope.$on('shifts.pendingConnections.refreshed', function(ev, pendingConnections) {
          return scope.pendingConnections = $rootScope.pendingConnections;
        });
        _do = function() {
          return $timeout(function() {
            scope.showMenuButton = nav.isFirstPage();
            return scope.showBackButton = !nav.isFirstPage();
          }, 1);
        };
        scope.appNavigator.on('prepush', _do);
        scope.appNavigator.on('prepop', _do);
        return _do();
      }
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.directive('shiftsSpinner', function() {
    return {
      restrict: 'E',
      replace: true,
      transclude: true,
      templateUrl: 'templates/directives/shiftsSpinner.html'
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.directive('shiftsUserAction', function(duration, nav) {
    return {
      restrict: 'EA',
      replace: true,
      templateUrl: 'templates/directives/shiftsUserAction.html',
      scope: {
        users: '=',
        listHeader: '@',
        acceptFunc: '&',
        declineFunc: '&'
      },
      link: function(scope) {
        scope.nav = nav;
        scope.accept = function(user) {
          return scope.acceptFunc({
            friend: user
          });
        };
        return scope.decline = function(user) {
          return scope.declineFunc({
            friend: user
          });
        };
      }
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.directive('shiftsUserList', function(duration, nav) {
    return {
      restrict: 'EA',
      replace: true,
      templateUrl: 'templates/directives/shiftsUserList.html',
      scope: {
        users: '=',
        listHeader: '@'
      },
      link: function(scope, element, attrs) {
        scope.nav = nav;
        scope.searchEnabled = _.has(attrs, 'enableSearch');
        scope.search = {
          term: void 0
        };
        return scope.cancelSearch = function() {
          scope.search.term = null;
          return scope.blur();
        };
      }
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.directive('shiftsWeekScroller', function($timeout) {
    return {
      restrict: 'A',
      scope: {
        selectedDayIndex: '=shiftsWeekScroller'
      },
      link: function(scope, element, attrs) {
        return scope.$watch('selectedDayIndex', function(newValue, oldValue) {
          var _do;
          if (newValue === oldValue) {
            return;
          }
          _do = function() {
            var isVisible, selectedDay;
            selectedDay = element.find('.week__day--selected');
            isVisible = selectedDay.visible();
            if (!isVisible) {
              return selectedDay[0].scrollIntoView();
            }
          };
          return $timeout(_do, 50);
        });
      }
    };
  });

}).call(this);

(function() {
  var padOut, qantasApp;

  qantasApp = angular.module('qantasApp');

  padOut = function(n, width, z) {
    z = z || '0';
    n = n + '';
    if (n.length >= width) {
      return n;
    } else {
      return new Array(width - n.length + 1).join(z) + n;
    }
  };

  qantasApp.directive('segment', function() {
    return {
      restrict: 'A',
      scope: {
        segment: '=',
        "default": '@'
      },
      link: function(scope, element, attrs) {
        var pad, prefix, sectionMap, targetLength;
        sectionMap = {
          start: 0,
          end: 3
        };
        prefix = sectionMap[scope.shiftSection];
        scope.hourIndex = prefix + 0;
        scope.minuteIndex = prefix + 1;
        scope.periodIndex = prefix + 2;
        pad = false;
        targetLength = 2;
        if (attrs.hasOwnProperty('pad')) {
          pad = true;
        }
        return scope.$watch('segment', function(newValue) {
          var toPad;
          if (newValue && newValue.length) {
            if (pad && newValue.length < targetLength) {
              toPad = targetLength - newValue.length;
              newValue = padOut(newValue, targetLength);
            }
            element.text(newValue);
            return element.removeClass('default-value');
          } else if (scope["default"] && scope["default"].length) {
            element.text(scope["default"]);
            return element.addClass('default-value');
          }
        });
      }
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('ConnectionResource', function($resource, transform) {
    return $resource(config.apiBase + "/v1/users/:userId/friends", {
      userId: 'userID'
    }, {
      get: {
        method: 'get',
        isArray: true,
        transformResponse: transform.response('users')
      },
      connect: {
        method: 'post',
        transformResponse: transform.response(null, {
          broadcast: 'shifts.connections.changed'
        })
      },
      unconnect: {
        method: 'delete',
        transformResponse: transform.response(null, {
          broadcast: 'shifts.connections.changed'
        })
      }
    });
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('ContactFindResource', function($resource, transform) {
    return $resource(config.apiBase + "/v1/contacts/find", {}, {
      find: {
        method: 'post',
        transformResponse: transform.response('data')
      }
    });
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('RosterCaptureResource', function($resource, transform) {
    return $resource(config.apiBase + "/v1/users/:userId/captures", {
      userId: '@userId'
    }, {
      save: {
        method: 'post',
        transformResponse: transform.response('capture')
      }
    });
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('SearchResource', function($resource, transform) {
    return $resource(config.apiBase + "/v1/search", {}, {
      searchUsers: {
        method: 'get',
        url: config.apiBase + "/v1/search/users",
        isArray: true,
        transformResponse: transform.response('results')
      }
    });
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('ShiftResource', function($resource, transform) {
    return $resource(config.apiBase + "/v1/shifts/:id", {
      id: '@id',
      userId: '@ownerId'
    }, {
      get: {
        method: 'get',
        transformResponse: transform.response('shift')
      },
      "delete": {
        method: 'delete',
        transformResponse: transform.response(null, {
          broadcast: 'shifts.shifts.changed'
        })
      },
      getForUser: {
        method: 'get',
        url: config.apiBase + "/v1/users/:userId/shifts",
        isArray: true,
        transformResponse: transform.response('shifts')
      }
    });
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('UserResource', function($resource, transform) {
    return $resource(config.apiBase + "/v1/users/:id", {
      id: '@id'
    }, {
      get: {
        method: 'get',
        transformResponse: transform.response('user')
      },
      update: {
        method: 'post',
        transformResponse: transform.response('user', {
          broadcast: 'shifts.user.changed'
        })
      },
      getConnections: {
        method: 'get',
        url: config.apiBase + "/v1/users/:id/friends",
        isArray: true,
        transformResponse: transform.response('users')
      },
      getPendingConnections: {
        method: 'get',
        url: config.apiBase + "/v1/users/:id/friends/pending",
        isArray: true,
        transformResponse: transform.response('users')
      }
    });
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('analyticsSetup', function($rootScope, $timeout, auth) {
    return function() {
      var _delay, _identify, _trackPage;
      _delay = function() {
        var func, ms;
        if (arguments.length === 1) {
          ms = 500;
          func = arguments[0];
        } else {
          ms = arguments[0], func = arguments[1];
        }
        return $timeout(func, ms);
      };
      _trackPage = function(ev) {
        var eventOptions, pageName, pageOptions, ref, ref1, ref2;
        pageOptions = ev.enterPage.options || {};
        eventOptions = _.omit(pageOptions, ['animation', 'animator', 'onTransitionEnd', '$title']);
        eventOptions = _.extend(eventOptions, {
          $userId: ((ref = auth.currentUser) != null ? ref.id : void 0) || void 0,
          $userDisplayName: ((ref1 = auth.currentUser) != null ? ref1.displayName : void 0) || void 0,
          $userEmail: ((ref2 = auth.currentUser) != null ? ref2.email : void 0) || void 0
        });
        pageName = ev.enterPage.name.split('/').pop().split('.')[0];
        pageName = pageOptions.$title || pageName;
        return analytics.page(pageName, eventOptions);
      };
      _identify = function() {
        return ons.ready(function() {
          var avatar, key, ref, ref1, ref2, user, userTraits, value;
          if (!auth.isAuthenticated()) {
            return;
          }
          user = auth.currentUser;
          if (user.profilePhoto) {
            avatar = user.profilePhoto.href + "/-/scale_crop/200x200/";
          } else {
            avatar = user.defaultPhoto + "&s=200";
          }
          userTraits = {
            id: user.id,
            email: user.email,
            name: user.displayName,
            avatar: avatar,
            isCordova: window.isCordova,
            userAgent: window.navigator.userAgent,
            createdAt: user.created,
            description: user.bio,
            connections: (ref = user.counts) != null ? ref.connections : void 0,
            futureShifts: (ref1 = user.counts) != null ? ref1.shifts : void 0,
            platform: window.platform
          };
          if (window.qantasAppVersion) {
            userTraits.appVersion = window.robbyAppVersion;
          }
          if (window.device) {
            ref2 = window.device;
            for (key in ref2) {
              value = ref2[key];
              userTraits["device_" + key] = value;
            }
          }
          return analytics.identify(user.id, userTraits);
        });
      };
      analytics.track('App startup');
      $rootScope.$on('login', function() {
        return _delay(function() {
          return ons.ready(function() {
            return $rootScope.appNavigator.on('postpush', _trackPage);
          });
        });
      });
      $rootScope.$on('login', _identify);
      return $rootScope.$on('register', _identify);
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('auth', function($rootScope, $window, $http, $q, pg, storage, UserResource) {
    var factory;
    window.pg = pg;
    factory = {
      currentUser: new UserResource()
    };
    $rootScope.currentUser = factory.currentUser;
    factory.hasTrait = function(trait) {
      var ref;
      return ((ref = factory.currentUser.traits) != null ? ref[trait] : void 0) === true;
    };
    factory.start = function() {
      var token, userInfo;
      token = storage.get('authToken');
      if (!token) {
        return;
      }
      userInfo = storage.get('userInfo') || {};
      _.extend(factory.currentUser, userInfo);
      return $http.get(config.apiBase + "/api").then(function(resp) {
        if (!resp.data.isAuthenticated) {
          factory.logout();
          return;
        }
        _.extend(factory.currentUser, userInfo, resp.data.user);
        storage.set('userInfo', factory.currentUser);
        return $http.get(config.apiBase + "/v1/users/" + factory.currentUser.id);
      }).then(function(resp) {
        _.extend(factory.currentUser, userInfo, resp.data.user);
        storage.set('userInfo', factory.currentUser);
        $rootScope.$broadcast('login', factory.currentUser);
      })["catch"](function(err) {
        var msg, ref;
        console.log('Error communicating with server on startup');
        console.log(err);
        if ((ref = err.status) === 400 || ref === 401 || ref === 403 || ref === 404) {
          msg = 'Login details have expired. Please log in again.';
          factory.logout();
        } else {
          msg = 'Error communicating with the server. Some functionality may not be available.';
        }
        pg.alert({
          msg: msg,
          title: 'Oops.'
        });
      });
    };
    factory.login = function(credentials) {
      var dfd, postLogin;
      dfd = $q.defer();
      postLogin = function(resp) {
        _.extend(factory.currentUser, resp.data.user);
        storage.set('userInfo', factory.currentUser);
        storage.set('authToken', resp.data.token);
        dfd.resolve(factory.currentUser);
        return $rootScope.$broadcast('login', factory.currentUser);
      };
      $http.post(config.apiBase + "/v1/auth/login", credentials).then(postLogin)["catch"](dfd.reject);
      return dfd.promise;
    };
    factory.register = function(credentials) {
      return $http.post(config.apiBase + "/v1/auth/register", credentials);
    };
    factory.logout = function(preventBroadcast) {
      storage.clearAll();
      factory.currentUser = new UserResource();
      if (!preventBroadcast) {
        $rootScope.$broadcast('logout', factory.currentUser);
      }
      return factory.currentUser;
    };
    factory.isAuthenticated = function() {
      return !!factory.currentUser.id;
    };
    return factory;
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('authInterceptor', function($rootScope, $q, storage, nav) {
    return {
      request: function(req) {
        var isApiCall, ref, token;
        if ((ref = window.templateHashes) != null ? ref[req.url] : void 0) {
          req.url = req.url + "?rel=" + window.templateHashes[req.url];
        }
        if (req.headers == null) {
          req.headers = {};
        }
        token = storage.get('authToken');
        isApiCall = req.url.indexOf(config.apiBase) === 0;
        if (token && isApiCall) {
          req.headers.Authorization = 'Bearer ' + token;
        }
        return req;
      },
      response: function(response) {
        if (response.status === 401) {
          console.error('server has invalidated token');
        }
        return response || $q.when(response);
      }
    };
  });

  qantasApp.config(function($httpProvider) {
    return $httpProvider.interceptors.push('authInterceptor');
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('calendar', function($http, $q, $rootScope, auth, prefs, pg, ShiftResource, formatFeed) {
    var _difference, _error, _fetchShifts, _fixDate, _noSupport, _success, _unicodeEscape, cal, factory, platformIsSupported, ref;
    cal = (ref = window.plugins) != null ? ref.calendar : void 0;
    platformIsSupported = cal != null;
    factory = {};
    document.addEventListener('deviceready', function() {
      var ref1;
      cal = (ref1 = window.plugins) != null ? ref1.calendar : void 0;
      return platformIsSupported = cal != null;
    });
    _unicodeEscape = function(str) {
      return str.replace(/[\s\S]/g, function(character) {
        var escape, longhand;
        escape = character.charCodeAt().toString(16);
        longhand = escape.length > 2;
        return '\\' + (longhand ? 'u' : 'x') + ('0000' + escape).slice(longhand ? -4 : -2);
      });
    };
    _noSupport = function() {
      return console.warn('Calendar is not supported on this platform, so skipping sync.');
    };
    _success = function(msg) {
      return console.log('Calendar success: ' + JSON.stringify(msg));
    };
    _error = function(msg) {
      return console.log('Calendar error: ' + JSON.stringify(msg));
    };
    window.onerror = function(msg, file, line) {
      return console.log(msg + '; ' + file + '; ' + line);
    };
    _fetchShifts = function() {
      return $http.get(config.apiBase + "/v1/users/" + auth.currentUser.id + "/feed").then(function(arg) {
        var data, feed, shifts;
        data = arg.data;
        feed = formatFeed(data);
        shifts = _.chain(feed).map(_.iteratee('shifts')).flatten().reject(_.iteratee('isDayOff')).value();
        return factory.saveEntries(shifts);
      });
    };
    _fixDate = function(dateString) {
      return dateString.replace(/-/g, '/');
    };
    _difference = function(shiftsServer, shiftsCalendar) {
      var shitsOnlyInServer;
      shitsOnlyInServer = shiftsServer.filter(function(server) {
        return shiftsCalendar.filter(function(calendar) {
          var calendarEnd, calendarStart, serverEnd, serverStart;
          calendarStart = new Date(_fixDate(calendar.startDate)).toISOString();
          calendarEnd = new Date(_fixDate(calendar.endDate)).toISOString();
          serverStart = new Date(server.start).toISOString();
          serverEnd = new Date(server.end).toISOString();
          return calendarStart === serverStart && calendarEnd === serverEnd;
        }).length === 0;
      });
      return shitsOnlyInServer;
    };
    factory.changeCalendar = function(oldCalendarName, oldEventTitle) {
      var calendarName, eventName;
      calendarName = oldCalendarName || 'Work Calendar';
      eventName = oldEventTitle || 'Work Shift';
      return pg.confirm({
        title: 'Changing Calendars',
        msg: 'Would you like to remove all your shifts from the old calendar?',
        buttons: {
          'Yes': function() {
            return factory.clearCalendar(calendarName, eventName).then((function() {
              return console.log('Calendar Cleared!');
            }), function(err) {
              return console.log(err);
            });
          },
          'No thanks': function() {
            return factory.addShiftsToCalendar();
          }
        }
      });
    };
    factory.clearCalendar = function(calendarName, eventTitle) {
      var _findError, _findSuccess, calendarOptions, dfd, endDate, loc, notes, startDate;
      dfd = $q.defer();
      calendarOptions = {};
      calendarOptions.calendarName = calendarName;
      loc = 'Work';
      notes = 'Created By Atum';
      startDate = new Date;
      endDate = new Date;
      startDate.setDate(startDate.getDate() - 712);
      endDate.setDate(endDate.getDate() + 712);
      _findSuccess = function(events) {
        var _removeSequentially, eventIndex;
        console.log(events);
        eventIndex = 0;
        _removeSequentially = function(events) {
          console.log(eventIndex);
          console.log(calendarName + ' - ' + eventTitle);
          return factory.removeEntryFromCalendarNamed(events[eventIndex], calendarName, eventTitle).then((function(msg) {
            eventIndex = eventIndex + 1;
            if (eventIndex < events.length) {
              return _removeSequentially(events);
            }
          }), function(err) {
            return console.log(err);
          });
        };
        _removeSequentially(events);
        return dfd.resolve();
      };
      _findError = function(err) {
        return dfd.reject(err);
      };
      if (deviceIsIOS) {
        cal.findEventWithOptions(eventTitle, loc, notes, startDate, endDate, calendarOptions, _findSuccess, _findError);
      }
      if (deviceIsAndroid) {
        cal.findEvent(eventTitle, loc, notes, startDate, endDate, _findSuccess, _findError);
      }
      return dfd.promise;
    };
    factory.syncEvents = function() {
      var _findError, _findSuccess, calendarOptions, endDate, eventTitle, loc, notes, startDate;
      calendarOptions = {};
      eventTitle = prefs.calendarTitle || 'Work Shift';
      calendarOptions.calendarName = prefs.calendarName || 'Work Calendar';
      loc = 'Work';
      notes = 'Created By Atum';
      startDate = new Date;
      endDate = new Date;
      endDate.setDate(endDate.getDate() + 712);
      _findSuccess = function(events) {
        var calendarEvents;
        calendarEvents = events;
        return $http.get(config.apiBase + "/v1/users/" + auth.currentUser.id + "/feed").then(function(arg) {
          var data, feed, serverShifts, shifts, shiftsNotInCalendar;
          data = arg.data;
          feed = formatFeed(data);
          shifts = _.chain(feed).map(_.iteratee('shifts')).flatten().reject(_.iteratee('isDayOff')).value();
          serverShifts = shifts;
          if (serverShifts.length > 0) {
            shiftsNotInCalendar = _difference(serverShifts, calendarEvents);
            if (shiftsNotInCalendar.length > 0) {
              return factory.saveEntries(shiftsNotInCalendar);
            }
          }
        });
      };
      _findError = function(err) {
        if (prefs.calendarSync) {
          return factory.addShiftsToCalendar();
        }
      };
      if (deviceIsIOS) {
        cal.findEventWithOptions(eventTitle, loc, notes, startDate, endDate, calendarOptions, _findSuccess, _findError);
      }
      if (deviceIsAndroid) {
        return cal.findEvent(eventTitle, loc, notes, startDate, endDate, _findSuccess, _findError);
      }
    };
    factory.saveEvent = function(event) {
      var _createError, _createSuccess, calendarOptions, dfd, endDate, eventTitle, loc, notes, startDate;
      dfd = $q.defer();
      calendarOptions = {};
      eventTitle = prefs.calendarTitle || 'Work Shift';
      calendarOptions.calendarName = prefs.calendarName || 'Work Calendar';
      loc = 'Work';
      notes = 'Created By Atum';
      startDate = new Date(_fixDate(event.startDate));
      endDate = new Date(_fixDate(event.endDate));
      _createSuccess = function(msg) {
        return dfd.resolve(JSON.stringify(msg));
      };
      _createError = function(msg) {
        return dfd.reject(JSON.stringify(msg));
      };
      if (deviceIsIOS) {
        cal.createEventWithOptions(eventTitle, loc, notes, starDate, endDate, calendarOptions, _createSuccess, _createError);
      }
      if (deviceIsAndroid) {
        cal.createEvent(eventTitle, loc, notes, starDate, endDate, _createSuccess, _createError);
      }
      return dfd.promise;
    };
    factory.removeEntryFromCalendarNamed = function(event, calendarName, eventTitle) {
      var _removeError, _removeSuccess, calendarOptions, dfd, endDate, loc, notes, startDate;
      dfd = $q.defer();
      calendarOptions = {};
      calendarOptions.calendarName = calendarName;
      loc = 'Work';
      notes = 'Created By Atum';
      startDate = new Date(_fixDate(event.startDate));
      endDate = new Date(_fixDate(event.endDate));
      _removeSuccess = function(msg) {
        return dfd.resolve(JSON.stringify(msg));
      };
      _removeError = function(msg) {
        return dfd.reject(JSON.stringify(msg));
      };
      if (deviceIsIOS) {
        cal.deleteEventFromNamedCalendar(eventTitle, loc, notes, startDate, endDate, calendarName, _removeSuccess, _removeError);
      }
      if (deviceIsAndroid) {
        cal.deleteEvent(eventTitle, loc, notes, startDate, endDate, _removeSuccess, _removeError);
      }
      return dfd.promise;
    };
    factory.removeEntry = function(shift) {
      var _removeError, _removeSuccess, calendarOptions, dfd, endDate, eventTitle, loc, notes, starDate;
      dfd = $q.defer();
      calendarOptions = {};
      eventTitle = prefs.calendarTitle || 'Work Shift';
      calendarOptions.calendarName = prefs.calendarName || 'Work Calendar';
      loc = 'Work';
      notes = 'Created By Atum';
      starDate = new Date(shift.start);
      endDate = new Date(shift.end);
      _removeSuccess = function(msg) {
        return dfd.resolve(JSON.stringify(msg));
      };
      _removeError = function(msg) {
        return dfd.reject(JSON.stringify(msg));
      };
      if (deviceIsIOS) {
        cal.deleteEventFromNamedCalendar(eventTitle, loc, notes, starDate, endDate, calendarOptions.calendarName, _removeSuccess, _removeError);
      }
      if (deviceIsAndroid) {
        cal.deleteEvent(eventTitle, loc, notes, starDate, endDate, _removeSuccess, _removeError);
      }
      return dfd.promise;
    };
    factory.saveEntries = function(shifts) {
      var _addSequentially, shiftIndex;
      shiftIndex = 0;
      _addSequentially = function(shifts) {
        return factory.saveEntry(shifts[shiftIndex]).then((function(msg) {
          shiftIndex = shiftIndex + 1;
          if (shiftIndex < shifts.length) {
            return _addSequentially(shifts);
          }
        }), function(err) {
          return console.log(err);
        });
      };
      return _addSequentially(shifts);
    };
    factory.saveEntry = function(shift) {
      var _createError, _createSuccess, calendarOptions, dfd, endDate, eventTitle, loc, notes, starDate;
      dfd = $q.defer();
      calendarOptions = {};
      eventTitle = prefs.calendarTitle || 'Work Shift';
      calendarOptions.calendarName = prefs.calendarName || 'Work Calendar';
      loc = 'Work';
      notes = 'Created By Atum';
      starDate = new Date(shift.start);
      endDate = new Date(shift.end);
      _createSuccess = function(msg) {
        return dfd.resolve(JSON.stringify(msg));
      };
      _createError = function(msg) {
        return dfd.reject(JSON.stringify(msg));
      };
      if (deviceIsIOS) {
        cal.createEventWithOptions(eventTitle, loc, notes, starDate, endDate, calendarOptions, _createSuccess, _createError);
      }
      if (deviceIsAndroid) {
        cal.createEvent(eventTitle, loc, notes, starDate, endDate, _createSuccess, _createError);
      }
      return dfd.promise;
    };
    factory.addShiftsToCalendar = function() {
      return _fetchShifts();
    };
    _.each(factory, function(func, funcName) {
      if (!_.isFunction(func)) {
        return;
      }
      return factory[funcName] = function() {
        if (!platformIsSupported) {
          return _noSupport();
        }
        return func.apply(null, arguments);
      };
    });
    return factory;
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('capturePhoto', function($q, pg) {
    return function(options, onceSelectedFn) {
      if (onceSelectedFn == null) {
        onceSelectedFn = function() {};
      }
      return pg.getPicture(options).then(function(img) {
        var fileUploadOptions;
        console.log('pre onceSelectedFn');
        onceSelectedFn();
        console.log('post onceSelectedFn');
        fileUploadOptions = {
          fileKey: 'file',
          fileSourceURI: img,
          uploadURI: 'https://upload.uploadcare.com/base/',
          params: {
            'UPLOADCARE_PUB_KEY': config.uploadcarePublicKey,
            'UPLOADCARE_STORE': 1
          }
        };
        return pg.fileTransferUpload(fileUploadOptions);
      }).then(function(resp) {
        return $q.when(JSON.parse(resp.response));
      });
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('contactSearch', function($q, $rootScope, prefs, $http, nav) {
    var _noSupport, factory, platformIsSupported, userContacts;
    userContacts = typeof navigator !== "undefined" && navigator !== null ? navigator.contacts : void 0;
    platformIsSupported = userContacts != null;
    factory = {};
    factory.contactOptions = new ContactFindOptions() || {};
    factory.contactOptions.multiple = true;
    factory.contactOptions.filter = '';
    factory.desiredFields = userContacts.fieldType.id;
    factory.fields = [userContacts.fieldType.emails, userContacts.fieldType.name];
    _noSupport = function() {
      return console.warn('Contact search is not supported on this platform');
    };
    factory.queryContacts = function() {
      var dfd, onError, onSuccess;
      dfd = $q.defer();
      onSuccess = function(contacts) {
        var contact, contactsEmails, i, len;
        contactsEmails = [];
        for (i = 0, len = contacts.length; i < len; i++) {
          contact = contacts[i];
          if ((contact.emails != null) && contact.emails.length > 0) {
            contactsEmails.push(contact.emails[0].value);
          }
        }
        return dfd.resolve(contactsEmails);
      };
      onError = function(err) {
        return dfd.reject(err);
      };
      if (deviceIsIOS) {
        userContacts.find(factory.fields, onSuccess, onError, factory.contactOptions);
      }
      if (deviceIsAndroid) {
        userContacts.find(factory.fields, onSuccess, onError, factory.contactOptions);
      }
      return dfd.promise;
    };
    return factory;
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('duration', function() {
    return function() {
      var dur, duration, durationPieces, end, mutate, ref, ref1, shift, start;
      shift = {};
      mutate = false;
      switch (arguments.length) {
        case 1:
          shift = (ref = arguments[0], start = ref.start, end = ref.end, ref);
          break;
        case 3:
          shift = (ref1 = arguments[0], start = ref1.start, end = ref1.end, ref1);
          mutate = true;
          break;
        case 2:
          start = arguments[0], end = arguments[1];
          break;
        default:
          throw new Error('Incorrect number of arguments');
      }
      dur = moment.duration(moment(end) - moment(start));
      durationPieces = [];
      if (dur.hours() === 1) {
        durationPieces.push('1 hour');
      } else if (dur.hours() > 1) {
        durationPieces.push((dur.hours()) + " hours");
      }
      if (dur.minutes() === 1) {
        durationPieces.push('1 minute');
      } else if (dur.minutes() > 1) {
        durationPieces.push((dur.minutes()) + " minutes");
      }
      duration = durationPieces.join(', ');
      if (mutate) {
        shift.duration = duration;
      }
      return duration;
    };
  });

}).call(this);

(function() {
  var qantasApp,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  qantasApp = angular.module('qantasApp');

  window._startTime = function() {
    return setInterval((function() {
      return console.log(new Date);
    }), 1000);
  };

  qantasApp.factory('localNotifications', function($rootScope, $q, pg, auth, storage, prefs, ShiftResource) {
    var LOCAL_SHIFT_REMINDER_STORAGE_KEY, LOCAL_STORAGE_KEY, NotificationPermissionsSoftReject, SHIFT_REMINDER_DELAY, SHIFT_REMINDER_MINUTES_DEFAULT, _defineLastShift, _fetchShiftsAndSyncNotifications, _makeNotificationID, _makeNotificationIDForShiftReminder, _makeShiftReminderNotification, _makeSingleNotification, _noSupport, factory, lastFetchedShifts, pgNotification, platformIsSupported, ref, shiftRemindNoti, skipFirstPrefChange;
    NotificationPermissionsSoftReject = (function(superClass) {
      extend(NotificationPermissionsSoftReject, superClass);

      function NotificationPermissionsSoftReject() {
        NotificationPermissionsSoftReject.__super__.constructor.apply(this, arguments);
      }

      return NotificationPermissionsSoftReject;

    })(Error);
    pgNotification = (ref = window.plugin) != null ? ref.notification : void 0;
    platformIsSupported = pgNotification != null ? pgNotification.local : void 0;
    LOCAL_STORAGE_KEY = 'localNotifications';
    LOCAL_SHIFT_REMINDER_STORAGE_KEY = 'shiftRemindNoti';
    SHIFT_REMINDER_MINUTES_DEFAULT = 120;
    SHIFT_REMINDER_DELAY = config.defaultShiftReminderTime;
    shiftRemindNoti = {};
    lastFetchedShifts = [];
    skipFirstPrefChange = true;
    document.addEventListener('deviceready', function() {
      var ref1;
      pgNotification = (ref1 = window.plugin) != null ? ref1.notification : void 0;
      platformIsSupported = pgNotification != null ? pgNotification.local : void 0;
      if (platformIsSupported) {
        return pgNotification.local.oncancelall = function() {};
      }
    });
    factory = {};
    _noSupport = function() {
      return console.warn('Local notifications are not supported on this platform, so skipping sync.');
    };
    _makeNotificationID = function(shift) {
      var rand, start;
      start = parseInt(new Date(shift.start).getTime() / 10000);
      rand = Math.floor(Math.random() * 1000) + 1;
      return parseInt(start + rand);
    };
    _makeNotificationIDForShiftReminder = function(scheduleDate) {
      var rand, start;
      start = parseInt(new Date(scheduleDate).getTime() / 10000);
      rand = Math.floor(Math.random() * 1000) + 1;
      return parseInt(start + rand);
    };
    _makeSingleNotification = function(shift) {
      var end, minutesBefore, newNoti, scheduledTime, start, timeUntil;
      minutesBefore = parseInt(prefs.shiftReminderMinutes || SHIFT_REMINDER_MINUTES_DEFAULT);
      scheduledTime = new Date(shift.start);
      scheduledTime.setMinutes(scheduledTime.getMinutes() - minutesBefore);
      if (scheduledTime < Date.now()) {
        return;
      }
      shift = _.omit(shift, 'coworkers');
      start = moment(shift.start).format('h:mm A');
      end = moment(shift.end).format('h:mm A');
      if (minutesBefore <= 90) {
        timeUntil = minutesBefore + " minutes";
      } else {
        timeUntil = (minutesBefore / 60) + " hours";
      }
      newNoti = {
        id: _makeNotificationID(shift),
        title: "Your shift starts in " + timeUntil + ".",
        text: "You work today from " + start + " to " + end,
        at: scheduledTime,
        data: {
          id: shift.id
        },
        badge: 0
      };
      return newNoti;
    };
    _fetchShiftsAndSyncNotifications = function() {
      return ShiftResource.getForUser({
        userId: auth.currentUser.id
      }).$promise.then(function(shifts) {
        return factory.syncShifts(shifts);
      });
    };
    _defineLastShift = function(shifts) {
      var endOfShift, finalScheduleDate, lastShiftInArray, remindShiftScheduleTime;
      if (shifts != null ? shifts.length : void 0) {
        lastShiftInArray = shifts[shifts.length - 1];
        endOfShift = new Date(lastShiftInArray.start);
        remindShiftScheduleTime = endOfShift.setMinutes(endOfShift.getMinutes() + SHIFT_REMINDER_DELAY);
        finalScheduleDate = new Date(remindShiftScheduleTime);
        return _makeShiftReminderNotification(finalScheduleDate);
      }
    };
    _makeShiftReminderNotification = function(scheduleDate) {
      factory.checkPermissions().then(function() {
        shiftRemindNoti = {
          id: _makeNotificationIDForShiftReminder(scheduleDate),
          title: 'You haven\'t addded your schedule in a while.',
          text: 'Just a friendly reminder to do so.',
          at: scheduleDate,
          badge: 0
        };
        factory.addSingleReminder(shiftRemindNoti);
        return console.log('shiftRemindNoti', shiftRemindNoti);
      });
      return shiftRemindNoti;
    };
    factory.softAskForPermissions = function() {
      var dfd;
      dfd = $q.defer();
      pg.confirm({
        title: 'Enable shift reminders?',
        msg: 'Atum can set notifications to remind you of upcomming shifts.\n\nThis can be changed later in Settings.',
        buttons: {
          'Enable': function() {
            dfd.resolve();
            return prefs.$set('softNotifcationPermission', true);
          },
          'No thanks': function() {
            dfd.reject(new NotificationPermissionsSoftReject());
            return prefs.$set({
              softNotifcationPermission: false,
              shiftReminderMinutes: 0
            });
          }
        }
      });
      return dfd.promise;
    };
    factory.checkPermissions = function() {
      var dfd, hasSoftGranted;
      dfd = $q.defer();
      hasSoftGranted = prefs.softNotifcationPermission;
      console.log('softNotifcationPermission', prefs.softNotifcationPermission);
      switch (hasSoftGranted) {
        case void 0:
          return factory.softAskForPermissions();
        case true:
          dfd.resolve();
          break;
        case false:
          dfd.reject(new NotificationPermissionsSoftReject());
      }
      return dfd.promise;
    };
    factory.clearAll = function() {
      var dfd;
      dfd = $q.defer();
      pgNotification.local.cancelAll(function() {
        storage.set(LOCAL_STORAGE_KEY, {});
        return dfd.resolve();
      });
      return dfd.promise;
    };
    factory.addMultiple = function(notifications) {
      var dfd;
      dfd = $q.defer();
      pgNotification.local.schedule(notifications, function() {
        var toStore;
        dfd.resolve();
        toStore = storage.get(LOCAL_STORAGE_KEY) || {};
        _.each(notifications, function(noti) {
          return toStore[noti.id] = noti;
        });
        return storage.set(LOCAL_STORAGE_KEY, toStore);
      });
      return dfd.promise;
    };
    factory.addSingleReminder = function(notification) {
      var dfd;
      dfd = $q.defer();
      pgNotification.local.schedule(notification, function() {
        var toStore;
        dfd.resolve();
        toStore = storage.get(LOCAL_SHIFT_REMINDER_STORAGE_KEY) || {};
        return storage.set(LOCAL_SHIFT_REMINDER_STORAGE_KEY, toStore);
      });
      return dfd.promise;
    };
    factory.syncShifts = function(shifts) {
      lastFetchedShifts = shifts;
      return factory.checkPermissions().then(function() {
        console.log('Permissions have been granted');
        return factory.clearAll();
      }).then(function() {
        var notifications;
        notifications = _.chain(shifts).map(_makeSingleNotification).filter(_.isObject).value();
        if (notifications.length) {
          return factory.addMultiple(notifications);
        }
      })["catch"](function(err) {
        if (err instanceof NotificationPermissionsSoftReject) {
          return console.warn('No permissions');
        } else {
          console.error('Unexpected error with local notifications:');
          return console.log(err.stack || err);
        }
      });
    };
    factory.syncOnShiftChanges = function() {
      $rootScope.$on('shifts.shifts.changed', _fetchShiftsAndSyncNotifications);
      return $rootScope.$on('shifts.prefs.changed', function() {
        if (skipFirstPrefChange) {
          skipFirstPrefChange = false;
          return;
        }
        if (prefs.shiftReminderMinutes <= 0) {
          return factory.clearAll();
        } else {
          return factory.syncShifts(lastFetchedShifts);
        }
      });
    };
    _.each(factory, function(func, funcName) {
      return factory[funcName] = function() {
        if (!platformIsSupported) {
          return _noSupport();
        }
        return func.apply(null, arguments);
      };
    });
    return factory;
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('nav', function($rootScope, $timeout, $window) {
    var _checkSwipableMenu, _isFirstPage, _moveTo, _replacePrevPage, forceMenuButton, titles;
    forceMenuButton = false;
    titles = {
      'profileCtrl': 'Profile',
      'feedCtrl': 'Shifts',
      'settingsCtrl': 'Settings',
      'searchCtrl': 'Search'
    };
    _moveTo = function(funcName, arg) {
      var options, page, template;
      page = arg[0], options = arg[1];
      template = "templates/" + page + ".html";
      if (options == null) {
        options = {};
      }
      options.$title = titles[page];
      return ons.ready(function() {
        $rootScope.appNavigator[funcName](template, options);
        return $rootScope.slidingMenu.close();
      });
    };
    _isFirstPage = function() {
      var pages;
      pages = $rootScope.appNavigator.getPages();
      if (forceMenuButton) {
        return true;
      }
      if (pages.length === 1) {
        return true;
      } else {
        return false;
      }
    };
    _checkSwipableMenu = function() {
      if (_isFirstPage()) {
        return $rootScope.slidingMenu.setSwipeable(true);
      } else {
        return $rootScope.slidingMenu.setSwipeable(false);
      }
    };
    _replacePrevPage = function(page) {
      var index, pages;
      pages = $rootScope.appNavigator.getPages();
      index = pages.length - 2;
      if (index < 0) {
        return;
      }
      $rootScope.appNavigator.insertPage(index, page);
      return pages.splice(index, 1);
    };
    $rootScope.$on('login', function(ev, currentUser) {
      var _do;
      _do = function() {
        return ons.ready(function() {
          if (!$rootScope.appNavigator) {
            return $timeout(_do, 1000);
          }
          $rootScope.appNavigator.on('postpush', _checkSwipableMenu);
          return $rootScope.appNavigator.on('postpop', _checkSwipableMenu);
        });
      };
      return $timeout(_do, 500);
    });
    return {
      openInAppBrowser: function(url) {
        return $window.open(url, '_blank', 'location=no,closebuttoncaption=Close,toolbarposition=top');
      },
      resetTo: function() {
        forceMenuButton = true;
        $rootScope.appNavigator.once('postpush', function() {
          return forceMenuButton = false;
        });
        $rootScope.appNavigator.once('postpop', function() {
          return forceMenuButton = false;
        });
        return _moveTo('resetToPage', arguments);
      },
      goto: function() {
        return _moveTo('pushPage', arguments);
      },
      setRootPage: function(page) {
        var template;
        template = "templates/" + page + ".html";
        return ons.ready(function() {
          return $rootScope.slidingMenu.setMainPage(template);
        });
      },
      getParams: function(key) {
        var page;
        page = $rootScope.appNavigator.getCurrentPage();
        if (key) {
          return page.options[key];
        } else {
          return page.options;
        }
      },
      back: function(page) {
        return ons.ready(function() {
          return $rootScope.appNavigator.popPage();
        });
      },
      isFirstPage: _isFirstPage,
      toggleMenu: function() {
        return ons.ready(function() {
          return $rootScope.slidingMenu.toggle();
        });
      },
      getBackButtonTitle: function() {
        var pageName, pageNameRegex, pages, previousPage;
        pages = $rootScope.appNavigator.getPages();
        if (!(pages.length > 1)) {
          return void 0;
        }
        previousPage = pages[pages.length - 2];
        pageNameRegex = /templates\/(.+).html/;
        pageName = previousPage.page.match(pageNameRegex)[1];
        return titles[pageName] || 'Back';
      }
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('pg', function($q, $rootScope, $templateCache, $onsen, DialogView, IOSAlertDialogAnimator) {
    var isCordova, navi, ref;
    isCordova = window.isCordova;
    navi = window.navigator;
    return {
      camera: navi.camera,
      notification: (ref = window.plugin) != null ? ref.notification : void 0,
      isCordova: window.isCordova,
      alert: function(arg) {
        var _cb, button, dfd, msg, title;
        msg = arg.msg, title = arg.title, button = arg.button;
        dfd = $q.defer();
        _cb = function(index) {
          return dfd.resolve();
        };
        if (isCordova) {
          navi.notification.alert(msg, _cb, title, button);
        } else {
          ons.notification.alert({
            message: msg,
            title: title,
            callback: _cb
          });
        }
        return dfd.promise;
      },
      confirm: function(arg) {
        var _cb, buttonActions, buttonLabels, buttons, dfd, func, label, msg, title;
        msg = arg.msg, title = arg.title, buttons = arg.buttons;
        dfd = $q.defer();
        _cb = function(index) {
          buttonActions[index]();
          return dfd.resolve();
        };
        buttonLabels = [];
        buttonActions = [function() {}];
        for (label in buttons) {
          func = buttons[label];
          buttonLabels.push(label);
          buttonActions.push(func);
        }
        if (isCordova) {
          if (window.isNativeAndroid && msg === void 0) {
            msg = title;
            title = ' ';
          }
          navi.notification.confirm(msg, _cb, title, buttonLabels);
        } else {
          if (title && !msg) {
            msg = title;
            title = void 0;
          }
          ons.notification.confirm({
            title: title,
            message: msg,
            buttonLabels: buttonLabels,
            callback: function(index) {
              return _cb(index + 1);
            }
          });
        }
        return dfd.promise;
      },
      actionSheet: function(config) {
        var _cleanup, actions, confName, dialog, dialogID, dialogName, i, len, pluginOptions, rawAction, ref1, template, templateName;
        actions = [null];
        pluginOptions = {
          title: config.title
        };
        if (config.destructive) {
          pluginOptions.addDestructiveButtonWithLabel = config.destructive.label;
          pluginOptions.androidEnableCancelButton = true;
          pluginOptions.winphoneEnableCancelButton = true;
          actions.push(config.destructive);
        }
        if (config.actions) {
          pluginOptions.buttonLabels = [];
          ref1 = config.actions;
          for (i = 0, len = ref1.length; i < len; i++) {
            rawAction = ref1[i];
            pluginOptions.buttonLabels.push(rawAction.label);
            actions.push(rawAction);
          }
        }
        if (config.cancel) {
          pluginOptions.addCancelButtonWithLabel = config.cancel.label;
          actions.push(config.cancel);
        }
        if (isCordova) {
          return window.plugins.actionsheet.show(pluginOptions, function(selected) {
            return actions[selected].action();
          });
        } else {
          dialog = null;
          dialogID = Math.random().toString(36).substr(2, 5);
          dialogName = "fakeDialog_" + dialogID;
          confName = dialogName + "_config";
          templateName = dialogName + ".html";
          $rootScope[confName] = config;
          _cleanup = function() {
            $rootScope[dialogName].destroy();
            delete $rootScope[confName];
            return delete $rootScope[dialogName];
          };
          config._tapped = function(selectedRow) {
            selectedRow.action();
            dialog.hide();
            window.lastDialog = dialog;
            return dialog.on('posthide', function() {
              return setTimeout(_cleanup, 0);
            });
          };
          template = "<ons-dialog var=\"" + dialogName + "\" cancelable animation=\"iosAlertStyle\">\n\n    <ons-list class=\"text-center\">\n        <ons-list-item modifier=\"tappable\" ng-repeat=\"row in " + confName + ".actions\" ng-click=\"" + confName + "._tapped(row)\">\n            {{row.label}}\n        </ons-list-item>\n\n        <ons-list-item modifier=\"tappable\" ng-if=\"" + confName + ".cancel\" ng-click=\"" + confName + "._tapped(" + confName + ".cancel)\">\n            <span class=\"semi-bold\">{{" + confName + ".cancel.label}}</span>\n        </ons-list-item>\n    </ons-list>\n\n</ons-dialog>";
          $templateCache.put(templateName, template);
          return ons.createDialog(templateName).then(function() {
            dialog = window[dialogName];
            return dialog.show();
          });
        }
      },
      openActionSheet: function(options) {
        var _cb, dfd;
        dfd = $q.defer();
        _cb = function(index) {
          return dfd.resolve(index);
        };
        window.plugins.actionsheet.show(options, _cb);
        return dfd.promise;
      },
      openShareSheet: function(arg) {
        var image, link, msg, subject;
        msg = arg.msg, subject = arg.subject, image = arg.image, link = arg.link;
        return window.plugins.socialsharing.share(msg, subject, image, link);
      },
      getPicture: function(options) {
        var _failure, _success, dfd, ref1, ref2, ref3, ref4, ref5, ref6;
        dfd = $q.defer();
        _success = function(img) {
          return dfd.resolve(img);
        };
        _failure = function(reason) {
          return dfd.reject(reason);
        };
        options.sourceType = (ref1 = navi.camera) != null ? (ref2 = ref1.PictureSourceType) != null ? ref2[options.sourceType.toUpperCase()] : void 0 : void 0;
        options.mediaType = (ref3 = navi.camera) != null ? (ref4 = ref3.MediaType) != null ? ref4[options.mediaType.toUpperCase()] : void 0 : void 0;
        options.cameraDirection = (ref5 = navi.camera) != null ? (ref6 = ref5.Direction) != null ? ref6[options.cameraDirection.toUpperCase()] : void 0 : void 0;
        if (isCordova) {
          navi.camera.getPicture(_success, _failure, options);
        } else {
          console.warn('Warning, can not open camera on non-cordova device');
          _failure('Camera not present on non-cordova device');
        }
        return dfd.promise;
      },
      fileTransferUpload: function(options) {
        var _failure, _success, dfd, fileSourceURI, ft, ftOptions, key, uploadURI, value;
        dfd = $q.defer();
        ftOptions = new FileUploadOptions();
        ft = new FileTransfer();
        fileSourceURI = options.fileSourceURI;
        uploadURI = options.uploadURI;
        delete options.fileSourceURI;
        delete options.uploadURI;
        for (key in options) {
          value = options[key];
          ftOptions[key] = value;
        }
        _success = function(resp) {
          return dfd.resolve(resp);
        };
        _failure = function(err) {
          return dfd.reject(err);
        };
        ft.upload(fileSourceURI, encodeURI(uploadURI), _success, _failure, ftOptions);
        return dfd.promise;
      }
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('phoneValidation', function($http, $q, $rootScope, auth, prefs) {
    var factory;
    factory = {};
    factory.selectedCountry = {
      phoneNumber: '',
      countryISO: ''
    };
    factory.getCountries = function() {
      var allCountries, c, i;
      allCountries = [['Afghanistan (‫افغانستان‬‎)', 'af', '93'], ['Albania (Shqipëri)', 'al', '355'], ['Algeria (‫الجزائر‬‎)', 'dz', '213'], ['American Samoa', 'as', '1684'], ['Andorra', 'ad', '376'], ['Angola', 'ao', '244'], ['Anguilla', 'ai', '1264'], ['Antigua and Barbuda', 'ag', '1268'], ['Argentina', 'ar', '54'], ['Armenia (Հայաստան)', 'am', '374'], ['Aruba', 'aw', '297'], ['Australia', 'au', '61'], ['Austria (Österreich)', 'at', '43'], ['Azerbaijan (Azərbaycan)', 'az', '994'], ['Bahamas', 'bs', '1242'], ['Bahrain (‫البحرين‬‎)', 'bh', '973'], ['Bangladesh (বাংলাদেশ)', 'bd', '880'], ['Barbados', 'bb', '1246'], ['Belarus (Беларусь)', 'by', '375'], ['Belgium (België)', 'be', '32'], ['Belize', 'bz', '501'], ['Benin (Bénin)', 'bj', '229'], ['Bermuda', 'bm', '1441'], ['Bhutan (འབྲུག)', 'bt', '975'], ['Bolivia', 'bo', '591'], ['Bosnia and Herzegovina (Босна и Херцеговина)', 'ba', '387'], ['Botswana', 'bw', '267'], ['Brazil (Brasil)', 'br', '55'], ['British Indian Ocean Territory', 'io', '246'], ['British Virgin Islands', 'vg', '1284'], ['Brunei', 'bn', '673'], ['Bulgaria (България)', 'bg', '359'], ['Burkina Faso', 'bf', '226'], ['Burundi (Uburundi)', 'bi', '257'], ['Cambodia (កម្ពុជា)', 'kh', '855'], ['Cameroon (Cameroun)', 'cm', '237'], ['Canada', 'ca', '1', 1, ['204', '226', '236', '249', '250', '289', '306', '343', '365', '387', '403', '416', '418', '431', '437', '438', '450', '506', '514', '519', '548', '579', '581', '587', '604', '613', '639', '647', '672', '705', '709', '742', '778', '780', '782', '807', '819', '825', '867', '873', '902', '905']], ['Cape Verde (Kabu Verdi)', 'cv', '238'], ['Caribbean Netherlands', 'bq', '599', 1], ['Cayman Islands', 'ky', '1345'], ['Central African Republic (République centrafricaine)', 'cf', '236'], ['Chad (Tchad)', 'td', '235'], ['Chile', 'cl', '56'], ['China (中国)', 'cn', '86'], ['Colombia', 'co', '57'], ['Comoros (‫جزر القمر‬‎)', 'km', '269'], ['Congo (DRC) (Jamhuri ya Kidemokrasia ya Kongo)', 'cd', '243'], ['Congo (Republic) (Congo-Brazzaville)', 'cg', '242'], ['Cook Islands', 'ck', '682'], ['Costa Rica', 'cr', '506'], ['Côte d’Ivoire', 'ci', '225'], ['Croatia (Hrvatska)', 'hr', '385'], ['Cuba', 'cu', '53'], ['Curaçao', 'cw', '599', 0], ['Cyprus (Κύπρος)', 'cy', '357'], ['Czech Republic (Česká republika)', 'cz', '420'], ['Denmark (Danmark)', 'dk', '45'], ['Djibouti', 'dj', '253'], ['Dominica', 'dm', '1767'], ['Dominican Republic (República Dominicana)', 'do', '1', 2, ['809', '829', '849']], ['Ecuador', 'ec', '593'], ['Egypt (‫مصر‬‎)', 'eg', '20'], ['El Salvador', 'sv', '503'], ['Equatorial Guinea (Guinea Ecuatorial)', 'gq', '240'], ['Eritrea', 'er', '291'], ['Estonia (Eesti)', 'ee', '372'], ['Ethiopia', 'et', '251'], ['Falkland Islands (Islas Malvinas)', 'fk', '500'], ['Faroe Islands (Føroyar)', 'fo', '298'], ['Fiji', 'fj', '679'], ['Finland (Suomi)', 'fi', '358'], ['France', 'fr', '33'], ['French Guiana (Guyane française)', 'gf', '594'], ['French Polynesia (Polynésie française)', 'pf', '689'], ['Gabon', 'ga', '241'], ['Gambia', 'gm', '220'], ['Georgia (საქართველო)', 'ge', '995'], ['Germany (Deutschland)', 'de', '49'], ['Ghana (Gaana)', 'gh', '233'], ['Gibraltar', 'gi', '350'], ['Greece (Ελλάδα)', 'gr', '30'], ['Greenland (Kalaallit Nunaat)', 'gl', '299'], ['Grenada', 'gd', '1473'], ['Guadeloupe', 'gp', '590', 0], ['Guam', 'gu', '1671'], ['Guatemala', 'gt', '502'], ['Guinea (Guinée)', 'gn', '224'], ['Guinea-Bissau (Guiné Bissau)', 'gw', '245'], ['Guyana', 'gy', '592'], ['Haiti', 'ht', '509'], ['Honduras', 'hn', '504'], ['Hong Kong (香港)', 'hk', '852'], ['Hungary (Magyarország)', 'hu', '36'], ['Iceland (Ísland)', 'is', '354'], ['India (भारत)', 'in', '91'], ['Indonesia', 'id', '62'], ['Iran (‫ایران‬‎)', 'ir', '98'], ['Iraq (‫العراق‬‎)', 'iq', '964'], ['Ireland', 'ie', '353'], ['Israel (‫ישראל‬‎)', 'il', '972'], ['Italy (Italia)', 'it', '39', 0], ['Jamaica', 'jm', '1876'], ['Japan (日本)', 'jp', '81'], ['Jordan (‫الأردن‬‎)', 'jo', '962'], ['Kazakhstan (Казахстан)', 'kz', '7', 1], ['Kenya', 'ke', '254'], ['Kiribati', 'ki', '686'], ['Kuwait (‫الكويت‬‎)', 'kw', '965'], ['Kyrgyzstan (Кыргызстан)', 'kg', '996'], ['Laos (ລາວ)', 'la', '856'], ['Latvia (Latvija)', 'lv', '371'], ['Lebanon (‫لبنان‬‎)', 'lb', '961'], ['Lesotho', 'ls', '266'], ['Liberia', 'lr', '231'], ['Libya (‫ليبيا‬‎)', 'ly', '218'], ['Liechtenstein', 'li', '423'], ['Lithuania (Lietuva)', 'lt', '370'], ['Luxembourg', 'lu', '352'], ['Macau (澳門)', 'mo', '853'], ['Macedonia (FYROM) (Македонија)', 'mk', '389'], ['Madagascar (Madagasikara)', 'mg', '261'], ['Malawi', 'mw', '265'], ['Malaysia', 'my', '60'], ['Maldives', 'mv', '960'], ['Mali', 'ml', '223'], ['Malta', 'mt', '356'], ['Marshall Islands', 'mh', '692'], ['Martinique', 'mq', '596'], ['Mauritania (‫موريتانيا‬‎)', 'mr', '222'], ['Mauritius (Moris)', 'mu', '230'], ['Mexico (México)', 'mx', '52'], ['Micronesia', 'fm', '691'], ['Moldova (Republica Moldova)', 'md', '373'], ['Monaco', 'mc', '377'], ['Mongolia (Монгол)', 'mn', '976'], ['Montenegro (Crna Gora)', 'me', '382'], ['Montserrat', 'ms', '1664'], ['Morocco (‫المغرب‬‎)', 'ma', '212'], ['Mozambique (Moçambique)', 'mz', '258'], ['Myanmar (Burma) (မြန်မာ)', 'mm', '95'], ['Namibia (Namibië)', 'na', '264'], ['Nauru', 'nr', '674'], ['Nepal (नेपाल)', 'np', '977'], ['Netherlands (Nederland)', 'nl', '31'], ['New Caledonia (Nouvelle-Calédonie)', 'nc', '687'], ['New Zealand', 'nz', '64'], ['Nicaragua', 'ni', '505'], ['Niger (Nijar)', 'ne', '227'], ['Nigeria', 'ng', '234'], ['Niue', 'nu', '683'], ['Norfolk Island', 'nf', '672'], ['North Korea (조선 민주주의 인민 공화국)', 'kp', '850'], ['Northern Mariana Islands', 'mp', '1670'], ['Norway (Norge)', 'no', '47'], ['Oman (‫عُمان‬‎)', 'om', '968'], ['Pakistan (‫پاکستان‬‎)', 'pk', '92'], ['Palau', 'pw', '680'], ['Palestine (‫فلسطين‬‎)', 'ps', '970'], ['Panama (Panamá)', 'pa', '507'], ['Papua New Guinea', 'pg', '675'], ['Paraguay', 'py', '595'], ['Peru (Perú)', 'pe', '51'], ['Philippines', 'ph', '63'], ['Poland (Polska)', 'pl', '48'], ['Portugal', 'pt', '351'], ['Puerto Rico', 'pr', '1', 3, ['787', '939']], ['Qatar (‫قطر‬‎)', 'qa', '974'], ['Réunion (La Réunion)', 're', '262'], ['Romania (România)', 'ro', '40'], ['Russia (Россия)', 'ru', '7', 0], ['Rwanda', 'rw', '250'], ['Saint Barthélemy (Saint-Barthélemy)', 'bl', '590', 1], ['Saint Helena', 'sh', '290'], ['Saint Kitts and Nevis', 'kn', '1869'], ['Saint Lucia', 'lc', '1758'], ['Saint Martin (Saint-Martin (partie française))', 'mf', '590', 2], ['Saint Pierre and Miquelon (Saint-Pierre-et-Miquelon)', 'pm', '508'], ['Saint Vincent and the Grenadines', 'vc', '1784'], ['Samoa', 'ws', '685'], ['San Marino', 'sm', '378'], ['São Tomé and Príncipe (São Tomé e Príncipe)', 'st', '239'], ['Saudi Arabia (‫المملكة العربية السعودية‬‎)', 'sa', '966'], ['Senegal (Sénégal)', 'sn', '221'], ['Serbia (Србија)', 'rs', '381'], ['Seychelles', 'sc', '248'], ['Sierra Leone', 'sl', '232'], ['Singapore', 'sg', '65'], ['Sint Maarten', 'sx', '1721'], ['Slovakia (Slovensko)', 'sk', '421'], ['Slovenia (Slovenija)', 'si', '386'], ['Solomon Islands', 'sb', '677'], ['Somalia (Soomaaliya)', 'so', '252'], ['South Africa', 'za', '27'], ['South Korea (대한민국)', 'kr', '82'], ['South Sudan (‫جنوب السودان‬‎)', 'ss', '211'], ['Spain (España)', 'es', '34'], ['Sri Lanka (ශ්‍රී ලංකාව)', 'lk', '94'], ['Sudan (‫السودان‬‎)', 'sd', '249'], ['Suriname', 'sr', '597'], ['Swaziland', 'sz', '268'], ['Sweden (Sverige)', 'se', '46'], ['Switzerland (Schweiz)', 'ch', '41'], ['Syria (‫سوريا‬‎)', 'sy', '963'], ['Taiwan (台灣)', 'tw', '886'], ['Tajikistan', 'tj', '992'], ['Tanzania', 'tz', '255'], ['Thailand (ไทย)', 'th', '66'], ['Timor-Leste', 'tl', '670'], ['Togo', 'tg', '228'], ['Tokelau', 'tk', '690'], ['Tonga', 'to', '676'], ['Trinidad and Tobago', 'tt', '1868'], ['Tunisia (‫تونس‬‎)', 'tn', '216'], ['Turkey (Türkiye)', 'tr', '90'], ['Turkmenistan', 'tm', '993'], ['Turks and Caicos Islands', 'tc', '1649'], ['Tuvalu', 'tv', '688'], ['U.S. Virgin Islands', 'vi', '1340'], ['Uganda', 'ug', '256'], ['Ukraine (Україна)', 'ua', '380'], ['United Arab Emirates (‫الإمارات العربية المتحدة‬‎)', 'ae', '971'], ['United Kingdom', 'gb', '44'], ['United States', 'us', '1', 0], ['Uruguay', 'uy', '598'], ['Uzbekistan (Oʻzbekiston)', 'uz', '998'], ['Vanuatu', 'vu', '678'], ['Vatican City (Città del Vaticano)', 'va', '39', 1], ['Venezuela', 've', '58'], ['Vietnam (Việt Nam)', 'vn', '84'], ['Wallis and Futuna', 'wf', '681'], ['Yemen (‫اليمن‬‎)', 'ye', '967'], ['Zambia', 'zm', '260'], ['Zimbabwe', 'zw', '263']];
      i = 0;
      while (i < allCountries.length) {
        c = allCountries[i];
        allCountries[i] = {
          name: c[0],
          iso2: c[1],
          dialCode: c[2],
          priority: c[3] || 0,
          areaCodes: c[4] || null
        };
        i++;
      }
      return allCountries;
    };
    factory.formatPhoneNumber = function(number) {
      if (prefs.countryISO != null) {
        return formatE164(prefs.countryISO, number);
      } else {
        return formatE164('us', number);
      }
    };
    factory.isNumberValid = function(number) {
      console.log('Number:');
      console.log(number);
      if (prefs.countryISO != null) {
        if (isValidNumber(number, prefs.countryISO)) {
          return true;
        } else {
          return false;
        }
      } else {
        if (isValidNumber(number, 'us')) {
          return true;
        } else {
          return false;
        }
      }
    };
    factory.getExampleNumber = function(iso) {
      var sampleNumber;
      return sampleNumber = formatInternational(iso, exampleMobileNumber(iso));
    };
    factory.setup = function() {
      if (prefs.countryISO != null) {
        factory.selectedCountry.countryISO = prefs.countryISO;
        return factory.selectedCountry.phoneNumber = factory.getExampleNumber(prefs.countryISO);
      } else {
        factory.selectedCountry.countryISO = 'us';
        return factory.selectedCountry.phoneNumber = factory.getExampleNumber('us');
      }
    };
    return factory;
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('prefs', function($rootScope, $http, auth, storage) {
    var CHANGED_EVENT_NAME, LS_KEY, factory, handleSettingsResponse, handleSettingsResponseError;
    LS_KEY = 'shiftsPrefs';
    CHANGED_EVENT_NAME = 'shifts.prefs.changed';
    factory = JSON.parse(storage.get(LS_KEY) || '{}');
    handleSettingsResponse = function(resp) {
      if (resp.status !== 200) {
        console.error('Unexpected response code');
        console.log(resp);
        return;
      }
      _.extend(factory, resp.data.settings);
      $rootScope.$broadcast(CHANGED_EVENT_NAME);
      return factory.$updateLocalStorage();
    };
    handleSettingsResponseError = function(resp) {
      console.log('settings http error:');
      return console.log(resp);
    };
    factory.$fetch = function() {
      return $http.get(config.apiBase + "/v1/users/" + auth.currentUser.id + "/settings").then(handleSettingsResponse)["catch"](handleSettingsResponseError);
    };
    factory.$updateLocalStorage = function() {
      return storage.set(LS_KEY, JSON.stringify(factory));
    };
    factory.$sync = function() {
      factory.$updateLocalStorage();
      return $http.post(config.apiBase + "/v1/users/" + auth.currentUser.id + "/settings", factory).then(handleSettingsResponse)["catch"](handleSettingsResponseError);
    };
    factory.$set = function() {
      var key, newOptions, value;
      if (arguments.length === 1) {
        newOptions = arguments[0];
        _.extend(factory, newOptions);
      } else {
        key = arguments[0], value = arguments[1];
        factory[key] = value;
      }
      $rootScope.$broadcast(CHANGED_EVENT_NAME);
      return factory.$sync();
    };
    return factory;
  });

}).call(this);

(function() {
  var qantasApp,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('pushNotifications', function($rootScope, $q, pg, auth, storage, prefs) {
    var NotificationPermissionsSoftReject, _noSupport, factory, onNotificationGCM, platformIsSupported, pushNotification, ref;
    NotificationPermissionsSoftReject = (function(superClass) {
      extend(NotificationPermissionsSoftReject, superClass);

      function NotificationPermissionsSoftReject() {
        NotificationPermissionsSoftReject.__super__.constructor.apply(this, arguments);
      }

      return NotificationPermissionsSoftReject;

    })(Error);
    pushNotification = (ref = window.plugins) != null ? ref.pushNotification : void 0;
    platformIsSupported = pushNotification != null;
    factory = {};
    _noSupport = function() {
      return console.warn('Push notifications are not supported on this platform, so skipping sync.');
    };
    factory.start = function() {
      var _errorHandler, _successHandler, _tokenHandler;
      if (deviceIsIOS) {
        _tokenHandler = function(deviceToken) {
          console.log('Token - ', deviceToken);
          prefs.$set('deviceID', deviceToken);
          prefs.$set('deviceType', 'IOS');
          if (prefs.deviceID != null) {
            return console.log('Device ID set for user');
          } else {
            return console.log('Could not set device id');
          }
        };
        _errorHandler = function(error) {
          return console.log('Error - ', error);
        };
        pushNotification.register(_tokenHandler, _errorHandler, {
          'badge': 'true',
          'sound': 'true',
          'alert': 'true',
          'ecb': 'onNotificationAPN'
        });
      }
      if (deviceIsAndroid) {
        _successHandler = function(token) {
          prefs.$set('deviceID', deviceToken);
          prefs.$set('deviceType', 'Android');
          if (prefs.deviceID != null) {
            return console.log('Device ID set for user');
          } else {
            return console.log('Could not set device id');
          }
        };
        _errorHandler = function(error) {
          return console.log('Error - ', error);
        };
        return pushNotification.register(_successHandler, _errorHandler, {
          'senderID': '295549078823',
          'ecb': 'onNotification'
        });
      }
    };
    onNotificationGCM = function(notificationReceived) {
      switch (notificationReceived.event) {
        case 'registered':
          if (notificationReceived.regid.length > 0) {
            deviceRegistered(notificationReceived.regid);
          }
          break;
        case 'message':
          if (notificationReceived.foreground) {
            alert(notificationReceived.message);
          }
          break;
        case 'error':
          console.log('Error: ' + notificationReceived.msg);
          break;
        default:
          console.log('An unknown event was received');
          break;
      }
    };
    _.each(factory, function(func, funcName) {
      return factory[funcName] = function() {
        if (!platformIsSupported) {
          return _noSupport();
        }
        return func.apply(null, arguments);
      };
    });
    return factory;
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('rosterCapture', function($q, $timeout, $http, auth, pg, storage, capturePhoto, RosterCaptureResource, geolocation, uploadcare) {
    var promptForGeo, self, showErrorMessage, showSuccessMessage;
    self = {};
    showErrorMessage = function(err) {
      var errMsg;
      window.uploadRosterCapture.hide();
      console.error('Error creating capture:');
      console.error(err);
      errMsg = 'There was an error uploading your schedule capture. Please try again later.';
      if (typeof err === 'string') {
        err = err.toLowerCase();
        if (err === 'no camera available') {
          errMsg = 'This device doese not have a camera!';
        } else if (err === 'no image selected') {
          return;
        }
      }
      return pg.alert({
        title: 'Oops',
        msg: errMsg
      });
    };
    showSuccessMessage = function() {
      window.uploadRosterCapture.hide();
      return pg.alert({
        title: 'Awesome',
        msg: 'We\'ll email you when your shifts have been added.'
      });
    };
    promptForGeo = function() {
      var approvedGeoAccess;
      approvedGeoAccess = storage.get('approvedGeoAccess');
      if (approvedGeoAccess) {
        return $q.when();
      }
      return pg.alert({
        title: 'Allow Geolocation',
        msg: 'Atum requires access to your location so we can accurately determine which time zone you\'re in',
        button: 'Continue'
      }).then(function() {
        storage.set('approvedGeoAccess', true);
        return $q.when();
      });
    };
    self.getTimezoneName = function() {
      return geolocation.getLocation().then(function(arg) {
        var coords, url;
        coords = arg.coords;
        url = "https://maps.googleapis.com/maps/api/timezone/json?key=" + config.googleTimeZoneApiKey + "&location=" + coords.latitude + "," + coords.longitude + "&timestamp=" + (Date.now() / 1000);
        return $http.get(url);
      }).then(function(arg) {
        var data;
        data = arg.data;
        return $q.when(data.timeZoneId);
      });
    };
    self.saveCapture = function(ucImageID, tzName) {
      var cap;
      cap = new RosterCaptureResource({
        ucImageID: ucImageID,
        tzName: tzName,
        userId: auth.currentUser.id
      });
      return cap.$save();
    };
    self.captureNatively = function(sourceType) {
      var cameraOptions;
      cameraOptions = {
        allowEdit: true,
        mediaType: 'PICTURE',
        cameraDirection: 'BACK',
        targetWidth: 1500,
        targetHeight: 3000,
        sourceType: sourceType || 'CAMERA'
      };
      return promptForGeo().then(function() {
        var tzPromise, uploadPromise;
        uploadPromise = capturePhoto(cameraOptions, function() {
          var _fn;
          _fn = function() {
            return window.uploadRosterCapture.show();
          };
          return $timeout(_fn, 10);
        });
        tzPromise = self.getTimezoneName();
        return $q.all([uploadPromise, tzPromise]);
      }).then(function(arg) {
        var file, ref, tzName;
        (ref = arg[0], file = ref.file), tzName = arg[1];
        console.log('All promises returned', arguments[0]);
        console.log('Got tzName', tzName + '. Now saving.');
        return self.saveCapture(file, tzName);
      }).then(showSuccessMessage)["catch"](showErrorMessage);
    };
    self.captureFromHtml = function(files) {
      var file, uploadPromise;
      file = files[0];
      if (!file) {
        return;
      }
      uploadPromise = uploadcare.upload(file);
      return promptForGeo().then(function() {
        var tzPromise;
        window.uploadRosterCapture.show();
        tzPromise = self.getTimezoneName();
        return $q.all([uploadPromise, tzPromise]);
      }).then(function(arg) {
        var tzName, uploadResult;
        uploadResult = arg[0], tzName = arg[1];
        return self.saveCapture(uploadResult.file, tzName);
      }).then(showSuccessMessage)["catch"](showErrorMessage);
    };
    return self;
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('selectNextShift', function(auth) {
    return function(feed) {
      var i, j, len, len1, now, ref, shift, week;
      if (feed.length === 0) {
        return {
          shift: null,
          shiftIsCurrent: null
        };
      }
      now = new Date();
      for (i = 0, len = feed.length; i < len; i++) {
        week = feed[i];
        ref = week.shifts;
        for (j = 0, len1 = ref.length; j < len1; j++) {
          shift = ref[j];
          if (shift.isDayOff || shift.ownerID !== auth.currentUser.id || shift.end < now) {
            continue;
          }
          if (now > shift.start && now < shift.end) {
            return {
              shiftIsCurrent: true,
              shift: shift
            };
          }
          return {
            shiftIsCurrent: false,
            shift: shift
          };
        }
      }
      return {
        shift: null,
        shiftIsCurrent: null
      };
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('storage', function($window) {
    var ls;
    ls = $window.localStorage;
    return {
      set: function(key, value) {
        return ls[key] = JSON.stringify(value);
      },
      get: function(key) {
        try {
          return JSON.parse(ls[key]);
        } catch (_error) {
          return void 0;
        }
      },
      clearAll: function() {
        return ls.clear();
      },
      remove: function(key) {
        return ls.removeItem(key);
      }
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('templatePrefetch', function($rootScope, $templateCache, $http, $q) {
    return {
      run: function() {
        var promise;
        promise = $q.when();
        window.config.prefetchAngularTemplates.forEach(function(templatePath) {
          if ($templateCache.get(templatePath)) {
            return;
          }
          return promise = promise.then(function() {
            return $http.get(templatePath);
          }).then(function(arg) {
            var body;
            body = arg.body;
            return $templateCache.put(templatePath, body);
          });
        });
        promise["catch"](function(err) {
          console.log('Error occcured while prefetching templates');
          return console.log(err);
        });
        return promise.then(function() {
          return $rootScope.$broadcast('shifts.templates.prefetchFinished');
        });
      }
    };
  });

}).call(this);

(function() {
  var qantasApp;

  qantasApp = angular.module('qantasApp');

  qantasApp.factory('uploadcare', function($upload) {
    return {
      upload: function(file) {
        return $upload.upload({
          url: 'https://upload.uploadcare.com/base/',
          fields: {
            'UPLOADCARE_PUB_KEY': config.uploadcarePublicKey,
            'UPLOADCARE_STORE': '1'
          },
          file: file
        }).then(function(arg) {
          var data;
          data = arg.data;
          return data;
        });
      }
    };
  });

}).call(this);
