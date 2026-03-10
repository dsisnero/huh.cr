require "../spec_helper"

module Huh
  describe Spinner do
    # Ported from vendor/spinner/spinner_test.go
    it "creates a new spinner" do
      spinner = Huh::Spinner.new
      spinner.should be_a(Spinner::Spinner)
    end

    it "sets title" do
      spinner = Huh::Spinner.new.title("Loading...")
      spinner.should be_a(Spinner::Spinner)
    end

    it "sets type" do
      spinner = Huh::Spinner.new.type(Huh::Spinner::Line)
      spinner.should be_a(Spinner::Spinner)
    end

    it "sets style" do
      style = Lipgloss::Style.new.foreground("#FF0000")
      spinner = Huh::Spinner.new.style(style)
      spinner.should be_a(Spinner::Spinner)
    end

    it "sets title style" do
      style = Lipgloss::Style.new.bold(true)
      spinner = Huh::Spinner.new.title_style(style)
      spinner.should be_a(Spinner::Spinner)
    end

    it "sets accessible mode" do
      spinner = Huh::Spinner.new.accessible(true)
      spinner.should be_a(Spinner::Spinner)
    end

    it "has spinner types defined" do
      Huh::Spinner::Line.should be_a(Huh::Spinner::Type)
      Huh::Spinner::Dot.should be_a(Huh::Spinner::Type)
      Huh::Spinner::MiniDot.should be_a(Huh::Spinner::Type)
      Huh::Spinner::Jump.should be_a(Huh::Spinner::Type)
      Huh::Spinner::Points.should be_a(Huh::Spinner::Type)
      Huh::Spinner::Pulse.should be_a(Huh::Spinner::Type)
      Huh::Spinner::Globe.should be_a(Huh::Spinner::Type)
      Huh::Spinner::Moon.should be_a(Huh::Spinner::Type)
      Huh::Spinner::Monkey.should be_a(Huh::Spinner::Type)
      Huh::Spinner::Meter.should be_a(Huh::Spinner::Type)
      Huh::Spinner::Hamburger.should be_a(Huh::Spinner::Type)
      Huh::Spinner::Ellipsis.should be_a(Huh::Spinner::Type)
    end

    it "can set action with block" do
      called = false
      spinner = Huh::Spinner.new.action do
        called = true
      end
      spinner.should be_a(Spinner::Spinner)
      # Note: action would be called when spinner runs
    end

    it "renders title in view" do
      spinner = Huh::Spinner.new.title("Test")
      spinner.view.should contain("Test")
    end

    it "returns non-nil init command" do
      spinner = Huh::Spinner.new
      spinner.init.should_not be_nil
    end

    it "handles ctrl+c in update" do
      spinner = Huh::Spinner.new
      ctrl_c = Tea::Key.new("", Tea::ModCtrl, 'c'.ord)
      _, cmd = spinner.update(ctrl_c)
      cmd.should_not be_nil
    end

    it "runs accessible spinner action without errors" do
      done = false
      Huh::Spinner.new
        .title("Loading...")
        .accessible(true)
        .action { done = true }
        .run
      done.should be_true
    end

    it "supports Go default title" do
      spinner = Huh::Spinner.new
      spinner.view.should contain("Loading...")
    end

    it "ports TestSpinnerContextCancellation (action completion exits model)" do
      spinner = Huh::Spinner.new.action { }
      spinner.init
      sleep 10.milliseconds

      _, cmd = spinner.update(Tea.key('x'))
      cmd.should_not be_nil
    end
  end
end
