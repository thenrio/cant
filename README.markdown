Intent
======

Lightweight authorization library, that let you choose where and how you write your rules

Cant is agnostic : you can use it in any existing or future framework, provided names don't clash

Cant is simple and small

Cant can be configured at class level, and support basic configuration inheritance

Concepts
========

Cant is a reduce (or [fold](http://learnyousomeerlang.com/higher-order-functions)) on a list of Rules.

* __Rule__ 

  a tuple of functions {__predicate__, __die__}.
  
* __rules__

  a list of __Rule__s

* __fold__

  function defining how __rules__ are traversed, and how each predicate is evaluated, and what is the result

  Cant provide two fold functions, returning both first __Rule__ that predicates, or nil

* __predicate__

  default rationale is : true means cant

* __die__

  a function, that can raise or return any result suitable to your need

* __cant?__

  calls fold function to operate on __rules__

* __die\_if\_cant!__

  calls fold function to operate on __rules__, and calls die function on result

How do I define a list of rules ?
=================================

First, choose where you want to define your list, and what information they will need have at hand

This can be any existing class, or a new one  

* a model (User, ...)
* a controller
* a middleware

Cant::Embeddable mixin propose to

* define rule and functions at class level
* evaluate predicates at instance level

Then there is one list of rules for any instance of this class, and instance evaluation leads to terser rules

Default Values
--------------

__Cant__ module has default values for __fold__, __die__, __rules__

The Cant::Editable module gather methods to configure a Cant engine (fold, die, rules), and defaults to Cant module values

Inheritance
-----------

Cant support _basic_ inheritance functionality for configuration with the Cant::Embeddable module ...
Ouch what that means ?

Well







What is the arity of a __predicate__ function ? 
-----------------------------------------------

You are free to pick one that suit your needs

There are a couple of things to drive your choice :

* number of params of in a rule list should be the same

* params of __cant?__ are passed to __predicate__

* the context of predicate evaluation (that is defined in fold function)
  the receiver methods will be available in function
  
* a container can be a handy parameter
  think of a _env_, _params_
  
* a block is a proc, and can use default values

Examples
--------

* in a model

        class User
          include Cant::Embeddable
      
          cant do |action, resource|
            (action == 'POST' and Code === resource) if drunk?
          end
        end

        deny {bob.cant? 'POST', kata}

* in a rails controller
      
        class AdminController < ApplicationController
          include Cant::Embeddable
          before_filter :authenticate_user!, :authorize_user!
      
          cant do |request|
            not (current_user.admin? or session[:admin])
          end
        end


How do I verify authorization ?
===============================

Cant very meaning takes a black list approach : you can unless you cant, and you define what you cant

Defining _not_ or _negative_ is less natural that defining do or positive ability, and I believe we can do it :)

Use __cant?__ method to check

Use __die\_if\_cant!__ method to check and run __die__ code

    
Inspired from
=============

[cancan]()
[koans]() for inheritable class instance variables    