require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate

  describe Application do
    before :each do
      @it = Application.new(nil, nil)
    end

    context "loading plugins" do
      before :each do 
        @files = ['a', 'b']
        Gem.stub!(:find_files).and_return(@files)
        Kernel.stub!(:load)
      end

      it "should look for files called germinate_plugin_v0_init.rb" do
        Gem.should_receive(:find_files).with('germinate_plugin_v0_init')
        @it.load_plugins!
      end

      it "should load the found files" do
        Kernel.should_receive(:load).with('a')
        Kernel.should_receive(:load).with('b')
        @it.load_plugins!
      end
    end
  end

end
