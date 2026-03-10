require "../spec_helper"
require "ansi"
require "../../src/huh/fields/note"

module Huh
  def self.keypress(r : Char) : Tea::KeyPressMsg
    Tea.key(r)
  end

  def self.submit_key : Tea::KeyPressMsg
    Tea.key(::Tea::KeyEnter)
  end

  def self.apply(form : Huh::Form, msg : ::Tea::Msg) : Huh::Form
    model, _ = form.update(msg)
    model
  end

  struct ParityNoopMsg
    include ::Tea::Msg
  end

  class ParitySkipField < Field(String)
    property focused : Bool = false

    def initialize(@label : String)
      super("")
    end

    def field_keymap
      nil
    end

    def init : Tea::Cmd?
      nil
    end

    def update(msg : ::Tea::Msg) : {self, Tea::Cmd?}
      {self, nil}
    end

    def view : String
      @label
    end

    def blur : Tea::Cmd?
      @focused = false
      nil
    end

    def focus : Tea::Cmd?
      @focused = true
      nil
    end

    def error : Exception?
      nil
    end

    def skip : Bool
      true
    end

    def zoom : Bool
      false
    end

    def key_binds : Array(KeyBinding)
      [] of KeyBinding
    end

    def run_accessible(writer : IO, reader : IO) : Nil
    end

    def focused? : Bool
      @focused
    end
  end

  describe "Go huh_test parity" do
    it "ports TestInput" do
      field = Huh.new_input
      form = Huh.new_form(Huh.new_group(field))
      form.init

      view = Ansi.strip(form.view)
      view.should contain(">")
      view.should contain("enter submit")

      form = Huh.apply(form, Huh.keypress('H'))
      form = Huh.apply(form, Huh.keypress('u'))
      form = Huh.apply(form, Huh.keypress('h'))

      view = Ansi.strip(form.view)
      view.should contain("Huh")
      field.get_value.should eq("Huh")
    end

    it "ports TestInlineInput" do
      field = Huh.new_input
        .title("Input ")
        .prompt(": ")
        .description("Description")
        .inline(true)

      form = Huh.new_form(Huh.new_group(field)).with_width(40)
      form.init
      view = Ansi.strip(form.view)
      view.should contain("Input Description:")

      form = Huh.apply(form, Huh.keypress('H'))
      form = Huh.apply(form, Huh.keypress('u'))
      form = Huh.apply(form, Huh.keypress('h'))
      view = Ansi.strip(form.view)

      view.should contain("Input Description: Huh")
      view.should contain("enter submit")
      field.get_value.should eq("Huh")
    end

    it "ports TestConfirm" do
      field = Huh.new_confirm.title("Are you sure?")
      form = Huh.new_form(Huh.new_group(field))
      form.init

      view = Ansi.strip(form.view)
      view.should contain("Yes")
      view.should contain("No")
      view.should contain("Are you sure?")
      view.should contain("toggle")

      form = Huh.apply(form, Huh.keypress('h'))
      field.get_value.should be_true

      form = Huh.apply(form, Huh.keypress('l'))
      field.get_value.should be_false
    end

    it "ports TestSelect" do
      field = Huh.new_select(String).options(Huh.new_options("Foo", "Bar", "Baz")).title("Which one?")
      form = Huh.new_form(Huh.new_group(field))
      form.init

      view = Ansi.strip(form.view)
      view.should contain("Foo")
      view.should contain("Which one?")
      view.should contain("> Foo")

      form = Huh.apply(form, Tea.key(::Tea::KeyDown))
      view = Ansi.strip(form.view)
      view.should_not contain("> Foo")
      view.should contain("> Bar")
      view.should contain("filter")

      form = Huh.apply(form, Huh.submit_key)
      field.get_value.should eq("Bar")
    end

    it "ports TestMultiSelect (selection behavior)" do
      field = Huh.new_multiselect(String).options(Huh.new_options("Foo", "Bar", "Baz")).title("Which one?")
      form = Huh.new_form(Huh.new_group(field))
      form.init

      view = Ansi.strip(form.view)
      view.should contain("Foo")
      view.should match(/>\s+•\s+Foo/)

      form = Huh.apply(form, Huh.keypress('j'))
      view = Ansi.strip(form.view)
      view.should match(/>\s+•\s+Bar/)

      form = Huh.apply(form, Huh.keypress('x'))
      view = Ansi.strip(form.view)
      view.should match(/>\s+✓\s+Bar/)
      view.should contain("toggle")
      view.should contain("filter")
    end

    it "ports TestMultiSelectFiltering" do
      filtering_on = Huh.new_multiselect(String)
        .options(Huh.new_options("Foo", "Bar", "Baz"))
        .title("Which one?")
        .filterable(true)
      form = Huh.new_form(Huh.new_group(filtering_on))
      form.init
      form = Huh.apply(form, Huh.keypress('/'))
      form = Huh.apply(form, Huh.keypress('B'))
      Ansi.strip(form.view).should_not contain("Foo")

      filtering_off = Huh.new_multiselect(String)
        .options(Huh.new_options("Foo", "Bar", "Baz"))
        .title("Which one?")
        .filterable(false)
      form2 = Huh.new_form(Huh.new_group(filtering_off))
      form2.init
      form2 = Huh.apply(form2, Huh.keypress('/'))
      view2 = Ansi.strip(form2.view)
      view2.should contain("Foo")
      view2.should_not contain("filter")
    end

    it "ports dynamic forms (title/description/options reevaluate across fields)" do
      source = Huh.cell("A")

      input = Huh.new_input
        .title("Source")
        .value(source)
      note = Huh::Note.new
        .title_func(-> { "Note #{source.value}" })
        .description_func(-> { "Desc #{source.value}" })
      select_field = Huh.new_select(String)
        .title_func(-> { "Select #{source.value}" })
        .description_func(-> { "Choose #{source.value}" })
        .options_func(-> {
          [
            Huh::Option.new("#{source.value} 1", "#{source.value}-1"),
            Huh::Option.new("#{source.value} 2", "#{source.value}-2"),
          ]
        })
      text = Huh.new_text
        .title_func(-> { "Text #{source.value}" })
        .description_func(-> { "Text desc #{source.value}" })

      form = Huh.new_form(Huh.new_group(input, note, select_field, text))
        .with_layout(Huh::Layout::LAYOUT_STACK)
      form.init
      form = Huh.apply(form, Huh::ParityNoopMsg.new)

      initial = Ansi.strip(form.view)
      initial.should contain("Note A")
      initial.should contain("A 1")
      initial.should contain("Text A")

      form = Huh.apply(form, Huh.keypress('B'))
      updated = Ansi.strip(form.view)

      updated.should contain("Note AB")
      updated.should contain("Desc AB")
      updated.should contain("Select AB")
      updated.should contain("AB 1")
      updated.should contain("Text AB")
    end

    it "ports TestForm (explicit group navigation)" do
      first = Huh.new_input.title("Group One")
      second = Huh.new_input.title("Group Two")
      form = Huh.new_form(
        Huh.new_group(first),
        Huh.new_group(second)
      )
      form.init

      Ansi.strip(form.view).should contain("Group One")
      form.selector.index.should eq(0)

      form = Huh.apply(form, Huh.next_group)
      form.selector.index.should eq(1)
      Ansi.strip(form.view).should contain("Group Two")
    end

    it "ports TestText (basic textarea input and help rendering)" do
      text = Huh.new_text.title("Story").description("Write a short story")
      form = Huh.new_form(Huh.new_group(text))
      form.init

      initial = Ansi.strip(form.view)
      initial.should contain("Story")
      initial.should contain("new line")

      form = Huh.apply(form, Huh.keypress('H'))
      form = Huh.apply(form, Huh.keypress('i'))
      text.get_value.should eq("Hi")
    end

    it "ports TestSelectPageNavigation (selection boundaries and unsupported page keys)" do
      field = Huh.new_select(String)
        .options(Huh.new_options("One", "Two", "Three", "Four"))
      form = Huh.new_form(Huh.new_group(field))
      form.init

      form = Huh.apply(form, Tea.key(::Tea::KeyUp))
      Ansi.strip(form.view).should contain("> One")

      4.times { form = Huh.apply(form, Tea.key(::Tea::KeyDown)) }
      Ansi.strip(form.view).should contain("> Four")

      form = Huh.apply(form, Huh.keypress('g'))
      form = Huh.apply(form, Huh.keypress('G'))
      Ansi.strip(form.view).should contain("> Four")
    end

    it "ports TestFile (file picker title and picking flow)" do
      field = Huh.new_filepicker
        .title("Pick a file")
        .description("Choose any file")
      form = Huh.new_form(Huh.new_group(field))
      form.init

      view = Ansi.strip(form.view)
      view.should contain("Pick a file")
      view.should contain("Choose any file")

      field.zoom.should be_false
      form = Huh.apply(form, Huh.keypress('/'))
      field.zoom.should be_true
      form = Huh.apply(form, Tea.key(::Tea::KeyEsc))
      field.zoom.should be_false
    end

    it "ports TestHideGroup (group boundaries include all groups)" do
      first = Huh.new_input.title("First")
      middle = Huh.new_input.title("Middle")
      last = Huh.new_input.title("Last")
      form = Huh.new_form(
        Huh.new_group(first),
        Huh.new_group(middle),
        Huh.new_group(last)
      )
      form.init

      first.position.not_nil!.first_group.should be_true
      first.position.not_nil!.last_group.should be_false
      middle.position.not_nil!.first_group.should be_false
      middle.position.not_nil!.last_group.should be_false
      last.position.not_nil!.first_group.should be_false
      last.position.not_nil!.last_group.should be_true
    end

    it "ports TestHideGroupLastAndFirstGroupsNotHidden (first/last remain navigable)" do
      first = Huh.new_input.title("First")
      last = Huh.new_input.title("Last")
      form = Huh.new_form(Huh.new_group(first), Huh.new_group(last))
      form.init

      first.position.not_nil!.first_group.should be_true
      first.position.not_nil!.last_group.should be_false
      last.position.not_nil!.first_group.should be_false
      last.position.not_nil!.last_group.should be_true
    end

    it "ports TestPrevGroup (backward group navigation)" do
      form = Huh.new_form(
        Huh.new_group(Huh.new_input.title("First")),
        Huh.new_group(Huh.new_input.title("Second"))
      )
      form.init
      form = Huh.apply(form, Huh.next_group)
      form.selector.index.should eq(1)

      form = Huh.apply(form, Huh.prev_group)
      form.selector.index.should eq(0)
      Ansi.strip(form.view).should contain("First")
    end

    it "ports TestNote (note rendering and no-op key update)" do
      note = Huh::Note.new
        .title("Information")
        .description("*bold* _italic_ `code`")
        .next(true)
        .next_label("Continue")
        .width(60)
      view = Ansi.strip(note.view)

      view.should contain("Information")
      view.should contain("bold")
      view.should contain("italic")
      view.should contain("code")
      view.should contain("Continue")

      _, cmd = note.update(Huh.keypress('x'))
      cmd.should be_nil
    end

    it "ports TestDynamicHelp (help footer updates with field focus)" do
      first = Huh.new_input.title("First")
      second = Huh.new_input.title("Second")
      form = Huh.new_form(Huh.new_group(first, second))
      form.init

      first_view = Ansi.strip(form.view)
      form = Huh.apply(form, Huh.next_field)
      second_view = Ansi.strip(form.view)

      first_view.should_not eq(second_view)
      second_view.should contain("submit")
    end

    it "ports TestSkip (skip fields are bypassed during navigation)" do
      skipped = Huh::ParitySkipField.new("Skipped")
      input = Huh.new_input.title("Answer")
      form = Huh.new_form(Huh.new_group(skipped, input))
      form.init

      form.selector.selected.selector.index.should eq(0)
      form = Huh.apply(form, Huh.next_field)
      form.selector.selected.selector.index.should eq(1)
      input.position.not_nil!.first_field.should be_true
    end

    it "ports TestTimeout (no implicit transition on no-op message)" do
      form = Huh.new_form(
        Huh.new_group(Huh.new_input.title("Only Group")),
        Huh.new_group(Huh.new_input.title("Second Group"))
      )
      form.init
      form.selector.index.should eq(0)

      form = Huh.apply(form, Huh::ParityNoopMsg.new)
      form.selector.index.should eq(0)
      Ansi.strip(form.view).should contain("Only Group")
    end

    it "ports TestAbort (no-op message does not abort navigation state)" do
      form = Huh.new_form(
        Huh.new_group(Huh.new_input.title("First")),
        Huh.new_group(Huh.new_input.title("Second"))
      )
      form.init
      form = Huh.apply(form, Huh.next_group)
      form.selector.index.should eq(1)

      form = Huh.apply(form, Huh::ParityNoopMsg.new)
      form.selector.index.should eq(1)

      form = Huh.apply(form, Huh.prev_group)
      form.selector.index.should eq(0)
    end
  end
end
