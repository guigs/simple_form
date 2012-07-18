require 'test_helper'

class WrapperTest < ActionView::TestCase
  test 'wrapper should not have error class for attribute without errors' do
    with_form_for @user, :active
    assert_no_select 'div.field_with_errors'
  end

  test 'wrapper should not have error class when object is not present' do
    with_form_for :project, :name
    assert_no_select 'div.field_with_errors'
  end

  test 'wrapper should add error class for attribute with errors' do
    with_form_for @user, :name
    assert_select 'div.field_with_errors'
  end

  test 'wrapper should add hint class for attribute with a hint' do
    with_form_for @user, :name, :hint => 'hint'
    assert_select 'div.field_with_hint'
  end

  test 'wrapper should not have disabled class by default' do
    with_form_for @user, :active
    assert_no_select 'div.disabled'
  end

  test 'wrapper should have disabled class when input is disabled' do
    with_form_for @user, :active, :disabled => true
    assert_select 'div.disabled'
  end

  test 'wrapper should support no wrapping when wrapper is false' do
    with_form_for @user, :name, :wrapper => false
    assert_select 'form > label[for=user_name]'
    assert_select 'form > input#user_name.string'
  end

  test 'wrapper should support no wrapping when wrapper tag is false' do
    with_form_for @user, :name, :wrapper => custom_wrapper_without_top_level
    assert_select 'form > label[for=user_name]'
    assert_select 'form > input#user_name.string'
  end

  test 'wrapper should wrapping tag adds required/optional css classes' do
    with_form_for @user, :name
    assert_select 'form div.input.required.string'

    with_form_for @user, :age, :required => false
    assert_select 'form div.input.optional.integer'
  end

  test 'wrapper should allow custom options to be given' do
    with_form_for @user, :name, :wrapper_html => { :id => "super_cool", :class => 'yay' }
    assert_select 'form #super_cool.required.string.yay'
  end

  test 'wrapper should allow tag to be given on demand' do
    with_form_for @user, :name, :wrapper_tag => :b
    assert_select 'form b.required.string'
  end

  test 'wrapper should allow wrapper class to be given on demand' do
    with_form_for @user, :name, :wrapper_class => :wrapper
    assert_select 'form div.wrapper.required.string'
  end

  test 'wrapper should skip additional classes when configured' do
    swap SimpleForm, :generate_additional_classes_for => [:input, :label] do
      with_form_for @user, :name, :wrapper_class => :wrapper
      assert_select 'form div.wrapper'
      assert_no_select 'div.required'
      assert_no_select 'div.string'
    end
  end

  test 'wrapper should not generate empty css class' do
    swap SimpleForm, :generate_additional_classes_for => [:input, :label] do
      swap_wrapper :default, custom_wrapper_without_class do
        with_form_for @user, :name
        assert_no_select 'div#custom_wrapper_without_class[class]'
      end
    end
  end

  # Custom wrapper test

  test 'custom wrappers works' do
    swap_wrapper do
      with_form_for @user, :name, :hint => "cool"
      assert_select "section.custom_wrapper div.another_wrapper label"
      assert_select "section.custom_wrapper div.another_wrapper input.string"
      assert_no_select "section.custom_wrapper div.another_wrapper span.omg_error"
      assert_select "section.custom_wrapper div.error_wrapper span.omg_error"
      assert_select "section.custom_wrapper > div.omg_hint", "cool"
    end
  end

  test 'custom wrappers can be turned off' do
    swap_wrapper do
      with_form_for @user, :name, :another => false
      assert_no_select "section.custom_wrapper div.another_wrapper label"
      assert_no_select "section.custom_wrapper div.another_wrapper input.string"
      assert_select "section.custom_wrapper div.error_wrapper span.omg_error"
    end
  end

  test 'custom wrappers on a form basis' do
    swap_wrapper :another do
      with_concat_form_for(@user) do |f|
        f.input :name
      end

      assert_no_select "section.custom_wrapper div.another_wrapper label"
      assert_no_select "section.custom_wrapper div.another_wrapper input.string"

      with_concat_form_for(@user, :wrapper => :another) do |f|
        f.input :name
      end

      assert_select "section.custom_wrapper div.another_wrapper label"
      assert_select "section.custom_wrapper div.another_wrapper input.string"
    end
  end

  test 'custom wrappers on input basis' do
    swap_wrapper :another do
      with_form_for @user, :name
      assert_no_select "section.custom_wrapper div.another_wrapper label"
      assert_no_select "section.custom_wrapper div.another_wrapper input.string"
      output_buffer.replace ""

      with_form_for @user, :name, :wrapper => :another
      assert_select "section.custom_wrapper div.another_wrapper label"
      assert_select "section.custom_wrapper div.another_wrapper input.string"
      output_buffer.replace ""
    end

    with_form_for @user, :name, :wrapper => custom_wrapper
    assert_select "section.custom_wrapper div.another_wrapper label"
    assert_select "section.custom_wrapper div.another_wrapper input.string"
  end

  test 'access wrappers with indifferent access' do
    swap_wrapper :another do
      with_form_for @user, :name, :wrapper => "another"
      assert_select "section.custom_wrapper div.another_wrapper label"
      assert_select "section.custom_wrapper div.another_wrapper input.string"
    end
  end

  test 'single element without wrap_with applies options to component tags' do
    swap_wrapper :default, custom_wrapper_with_no_wrapping_tag do
      with_form_for @user, :name
      assert_select "div.custom_wrapper div.elem input.input_class_yo"
      assert_select "div.custom_wrapper div.elem input.other_class_yo"
      assert_select "div.custom_wrapper div.elem input.string"
      assert_select "div.custom_wrapper div.elem label[data-yo='yo']"
      assert_select "div.custom_wrapper div.elem span.custom_yo", :text => "custom"
      assert_select "div.custom_wrapper div.elem label.both_yo"
      assert_select "div.custom_wrapper div.elem input.both_yo"
    end
  end

  test 'single element with wrap with and component options applies to both' do
    swap_wrapper :default, custom_wrapper_with_wrapping_tag_and_component_options do
      with_form_for @user, :name
      assert_no_select "div.custom_wrapper > input"
      assert_select "div.custom_wrapper div.wrap input.input_class_yo"
      assert_select "div.custom_wrapper div.wrap input.other_class_yo"
    end
  end

  test 'adding any option to tag components on the input ignores them' do
    with_concat_form_for @user do |f|
      concat f.input :name, :invalid => 'thing'
    end
    assert_no_select "input[invalid='thing']"
  end

  test 'adding any option to tag components in wrapper makes html attributes' do
    swap_wrapper :default, custom_wrapper_with_wrong_wrapping_tag do
      with_input_for @user, :name, :string, :other_invalid => 'other_thing'
      assert_select "input[invalid='thing']"
      assert_select "input.input_class_yo"
      assert_no_select "input[other_invalid='other_thing']"
    end
  end

  test 'adding invalid options to non-tag components issues a warning but otherwise works' do
    out, err = capture_io do
      swap_wrapper :default, custom_wrapper_with_invalid_options do
        with_form_for @user, :name
        assert_select "div.custom_wrapper input[name='user[name]']"
      end
    end
    assert_match /Invalid options \[:class\] passed to placeholder./, err
    assert_match /Invalid options \[(:id|:class), (:class|:id)\] passed to hint./, err
  end

  test 'do not duplicate label classes for different inputs' do
    swap_wrapper :default, self.custom_wrapper_with_label_html_option do
      with_concat_form_for(@user) do |f|
        concat f.input :name, :required => false
        concat f.input :email, :as => :email, :required => true
      end

      assert_select "label.string.optional.extra-label-class[for='user_name']"
      assert_select "label.email.required.extra-label-class[for='user_email']"
      assert_no_select "label.string.optional.extra-label-class[for='user_email']"
    end
  end

  test 'raise error when wrapper not found' do
    assert_raise SimpleForm::WrapperNotFound do
      with_form_for @user, :name, :wrapper => :not_found
    end
  end
end
