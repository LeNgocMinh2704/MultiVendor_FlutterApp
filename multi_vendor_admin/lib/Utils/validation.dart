import 'package:flutter/cupertino.dart';

class Validation with ChangeNotifier {
  String? validateName(arg) {
    notifyListeners();
    if (arg == '') {
      return 'Name is Required';
    } else {
      return null;
    }
  }

  String? validateAddress(arg) {
    notifyListeners();
    if (arg == '') {
      return 'Address is Required';
    } else {
      return null;
    }
  }

  String? validateZip(arg) {
    notifyListeners();
    if (arg == '') {
      return 'ZipCode is Required';
    } else {
      return null;
    }
  }

  String? validatePassword(String? arg, String password) {
    notifyListeners();
    if (arg!.length <= 5 || arg != password) {
      return 'Pasword must be up to 6 digits';
    } else {
      return null;
    }
  }

  String? validateEmail(String? value, String username) {
    notifyListeners();
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern.toString());
    if (!regex.hasMatch(value!) || value != username) {
      return 'Enter a valid Email';
    } else {
      return null;
    }
  }

  String? validatePhone(String? value) {
    notifyListeners();
    if (value!.length != 11) {
      return 'Enter a valid Phonenumber';
    } else {
      return null;
    }
  }

  String? validateCard(arg) {
    notifyListeners();
    if (arg == '') {
      return 'Field is Required';
    } else {
      return null;
    }
  }

  String? validateProductName(arg) {
    notifyListeners();
    if (arg == '') {
      return 'Product Name is required';
    } else {
      return null;
    }
  }

  String? validateDescription(String? value) {
    notifyListeners();
    if (value == '') {
      return 'Product Description is required';
    } else {
      return null;
    }
  }

  String? validateProductPrice(String? value) {
    notifyListeners();
    if (value == '') {
      return 'Product Price is required';
    } else {
      return null;
    }
  }

  String? validateSize(String? value) {
    notifyListeners();
    if (value == '') {
      return 'Size is required';
    } else {
      return null;
    }
  }

  String? validateTitle(String? value) {
    notifyListeners();
    if (value == '') {
      return 'Title is required';
    } else {
      return null;
    }
  }
}
