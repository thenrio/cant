Intent
======

Lightweight authorization library, that let you choose where and how you write your rules

Cant is agnostic : you can use it in any existing or future framework, provided names don't clash

Cant is small and even simple

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

First, choose where you want to define your list, and what information a Rule will need

The point of cant is to define a lists of similar rules together, so that they will require similar informations

A list of rules can be embedded in an existing class using Cant::Embeddable mixin

* define rule and functions at class level
* evaluate predicates at instance level

Then there is one list of rules for any instance of this class, and instance evaluation leads to terser rules

Note that a list of rules can be shared by many inquirers, either explicitly or by using class instance variable inheritance feature

Default Values
--------------

__Cant__ module has "reasonable" default values for __fold__, __die__, __rules__

The Cant::Editable module gather methods to configure a Cant engine (fold, die, rules), and defaults to Cant module values

Inheritance
-----------

Cant support _basic_ inheritance functionality for configuration with the Cant::Embeddable module ...
Ouch what that means ?

    Given Admin inherits from User
      And User.die {"I'm not dead!"}
    Then assert {Admin.die.call == "I'm not dead!"} is true

Well, have a look at read documentation and source code embeddable.rb if you are having trouble with this functionality

What is the arity of a __predicate__ function ? 
-----------------------------------------------

You are free to pick one that suit your needs

There are a couple of things to drive your choice :

* params of __cant?__ are passed to __predicate__

* params of __die\_if\_cant!__ are passed to __predicate__ and __die!__

* number and order of params of in a rule list should be the same

* the context of predicate evaluation (that is defined in fold function)
  the receiver methods will be available in function
  
* a container can be a handy parameter
  _env_, _params_
  
* a block is a proc, and can use default values for params

Examples
--------

* in an existing model

        class User
          include Cant::Embeddable
      
          cant do |action, resource|
            (action == :post and Code === resource) if drunk?
          end
        end

        assert {bob.cant? :post, kata}

* in a separate model
        
        class Permission
          include Cant::Embeddable
      
          cant do |user, action, resource|
            (action == :post and Code === resource) if user.drunk?
          end
        end

        assert {permission.cant? bob, :post, kata}        

* in a controller
      
        class KatasController < ApplicationController
          include Cant::Embeddable
          before_filter :authenticate_user!, :authorize_user!
      
          cant do |request|
            current_user.drunken? if request.method == 'POST'
          end
        end
        
        deny {cant? request}

So you can pick your own semantic and specification for writing your rules

How do I verify authorization ?
===============================

Cant very meaning is : you can unless you cant, and you define what you cant

Defining _not_ or _negative_ ability require some thinking, and I believe we can do it :)

Use __cant?__ method to check

Use __die\_if\_cant!__ method to check and run __die__ code

When you check, provide the list of parameters you specified in your list of rules

Inspired from
=============

* [cancan](https://github.com/ryanb/cancan), as I started with it and saw that it did not functioned in presence of mongoid as of < 1.5 ... so I planned to do something no dependent of a model implementation

* [learn you some erlang?](http://learnyousomeerlang.com/higher-order-functions#maps-filters-folds), for the fold illustrations

* [Howard](http://rubyquiz.com/quiz67.html) and [Nunemaker](http://railstips.org/blog/archives/2006/11/18/class-and-instance-variables-in-ruby/) for inheritable class instance variables

Help|Contribute
===============

Fill an item in tracker

Add a spec, and open a pull request with topic branch