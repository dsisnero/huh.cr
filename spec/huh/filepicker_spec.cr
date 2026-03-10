require "../spec_helper"

module Huh
  describe FilePicker do
    it "creates a new filepicker" do
      fp = Huh.new_filepicker
      fp.should be_a(FilePicker)
    end

    it "sets title" do
      fp = Huh.new_filepicker.title("Select a file")
      fp.title.should eq("Select a file")
    end

    it "sets description" do
      fp = Huh.new_filepicker.description("Choose a file from the filesystem")
      fp.description.should eq("Choose a file from the filesystem")
    end

    it "sets current directory" do
      fp = Huh.new_filepicker.current_directory("/tmp")
      # Note: We can't easily test the internal filepicker state without mocking
      fp.should be_a(FilePicker)
    end

    it "sets allowed types" do
      fp = Huh.new_filepicker.allowed_types([".txt", ".md"])
      fp.allowed_types.should eq([".txt", ".md"])
    end

    it "sets file allowed" do
      fp = Huh.new_filepicker.file_allowed(true)
      fp.file_allowed?.should be_true
    end

    it "sets dir allowed" do
      fp = Huh.new_filepicker.dir_allowed(false)
      fp.dir_allowed?.should be_false
    end

    it "sets show hidden" do
      fp = Huh.new_filepicker.show_hidden(true)
      fp.show_hidden?.should be_true
    end

    it "sets show size" do
      fp = Huh.new_filepicker.show_size(true)
      fp.show_size?.should be_true
    end

    it "sets show permissions" do
      fp = Huh.new_filepicker.show_permissions(true)
      fp.show_permissions?.should be_true
    end

    it "sets value with cell" do
      cell = Cell(String).new("")
      fp = Huh.new_filepicker.value(cell)
      fp.get.should eq("")
    end

    it "validates with block" do
      cell = Cell(String).new("")
      fp = Huh.new_filepicker.value(cell).validate do |p|
        unless p.ends_with?(".txt")
          Exception.new("Must be a .txt file")
        end
      end

      fp.set("test.md")
      fp.error.should be_a(Exception)
      fp.error.not_nil!.message.should eq("Must be a .txt file")

      fp.set("test.txt")
      fp.error.should be_nil
    end

    it "has key binds" do
      fp = Huh.new_filepicker
      binds = fp.key_binds
      binds.should be_a(Array(Huh::KeyBinding))
      binds.size.should be > 0
    end

    it "can focus and blur" do
      fp = Huh.new_filepicker
      cmd = fp.focus
      cmd.should be_a(Tea::Cmd?)
      fp.focused?.should be_true

      cmd = fp.blur
      cmd.should be_nil
      fp.focused?.should be_false
    end

    it "renders view" do
      fp = Huh.new_filepicker.title("Test FilePicker")
      view = fp.view
      view.should be_a(String)
      view.should contain("Test FilePicker")
    end
  end
end
