require 'spec_helper'

describe "Mods <titleInfo> element" do
  
  before(:all) do
    @mods_rec = Mods::Record.new
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
  end
  
  context "WITH namespaces" do
    
    it "should recognize type attribute on titleInfo element" do
      Mods::TitleInfo::TYPES.each { |t|
        @mods_rec.from_str("<mods #{@ns_decl}><titleInfo type='#{t}'>hi</titleInfo></mods>")
        @mods_rec.title_info.type_at.should == [t]
      }
    end
    it "should recognize subelements" do
      Mods::TitleInfo::CHILD_ELEMENTS.each { |e|
        @mods_rec.from_str("<mods #{@ns_decl}><titleInfo><#{e}>oofda</#{e}></titleInfo></mods>")
        @mods_rec.title_info.send(e).text.should == 'oofda'
      }
    end

    context "short_title" do
      it "should start with nonSort element" do
        @mods_rec.from_str("<mods #{@ns_decl}><titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo></mods>")
        @mods_rec.title_info.short_title.should == ["The Jerk"]
      end
      it "should not include subtitle" do
        @mods_rec.from_str("<mods #{@ns_decl}><titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo></mods>")
        @mods_rec.title_info.short_title.should == ["The Jerk"]
      end
      it "Mods::Record.short_titles convenience method should return an Array (multiple titles are legal in Mods)" do
        @mods_rec.from_str("<mods #{@ns_decl}><titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo><titleInfo><title>Joke</title></titleInfo></mods>")
        @mods_rec.short_titles.should == ["The Jerk", "Joke"]
      end
      it "should not include alternative titles" do
        @mods_rec.from_str("<mods #{@ns_decl}><titleInfo type='alternative'><title>ta da!</title></titleInfo></mods>")
        @mods_rec.short_titles.should_not include("ta da!")
        @mods_rec.from_str("<mods #{@ns_decl}><titleInfo type='alternative'><title>1</title></titleInfo><titleInfo><title>2</title></titleInfo></mods>")
        @mods_rec.short_titles.should == ['2']
      end
      # note that Mods::Record.short_title tests are in record_spec
    end

    context "full_title" do
      it "should start with nonSort element" do
        @mods_rec.from_str("<mods #{@ns_decl}><titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo></mods>")
        @mods_rec.title_info.full_title.should == ["The Jerk"]
      end
      it "should include subtitle" do
        @mods_rec.from_str("<mods #{@ns_decl}><titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo></mods>")
        @mods_rec.title_info.full_title.should == ["The Jerk A Tale of Tourettes"]
      end
      it "Mods::Record.full_titles convenience method should return an Array (multiple titles are legal in Mods)" do
        @mods_rec.from_str("<mods #{@ns_decl}><titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo><titleInfo><title>Joke</title></titleInfo></mods>")
        @mods_rec.full_titles.should == ["The Jerk", "Joke"]
      end
      # note that Mods::Record.full_title tests are in record_spec
    end

    context "sort_title" do
      it "should skip nonSort element" do
        @mods_rec.from_str("<mods #{@ns_decl}><titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo></mods>")
        @mods_rec.title_info.sort_title.should == ["Jerk"]
      end
      it "should contain title and subtitle" do
        @mods_rec.from_str("<mods #{@ns_decl}><titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo></mods>")
        @mods_rec.title_info.sort_title.should == ["Jerk A Tale of Tourettes"]
      end
      it "should be an alternative title if there are no other choices" do
        @mods_rec.from_str("<mods #{@ns_decl}><titleInfo type='alternative'><title>1</title></titleInfo></mods>")
        @mods_rec.title_info.sort_title.should == ['1']
      end
      it "should not be an alternative title if there are other choices" do
        @mods_rec.from_str("<mods #{@ns_decl}><titleInfo type='alternative'><title>1</title></titleInfo><titleInfo><title>2</title></titleInfo></mods>")
        @mods_rec.title_info.sort_title.should == ['2']
        @mods_rec.sort_title.should == '2'
      end
      it "should have a configurable delimiter between title and subtitle" do
        m = Mods::Record.new(' : ')
        m.from_str("<mods #{@ns_decl}><titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo></mods>")
        m.title_info.sort_title.should == ["Jerk : A Tale of Tourettes"]
      end
      context "Mods::Record.sort_title convenience method" do
        it "convenience method sort_title in Mods::Record should return a string" do
          @mods_rec.from_str("<mods #{@ns_decl}><titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo></mods>")
          @mods_rec.sort_title.should == "Jerk A Tale of Tourettes"
        end
      end
      # note that Mods::Record.sort_title tests are in record_spec
    end

    context "alternative_title" do
      it "should get an alternative title, if it exists" do
        @mods_rec.from_str("<mods #{@ns_decl}><titleInfo type='alternative'><title>ta da!</title></titleInfo></mods>")
        @mods_rec.title_info.alternative_title.should == ["ta da!"]
      end
      it "Mods::Record.alternative_titles convenience method for getting an Array of alternative titles when there are multiple elements" do
        @mods_rec.from_str("<mods #{@ns_decl}><titleInfo type='alternative'><title>1</title></titleInfo><titleInfo type='alternative'><title>2</title></titleInfo></mods>")
        @mods_rec.alternative_titles.should == ['1', '2']
        @mods_rec.from_str("<mods #{@ns_decl}><titleInfo type='alternative'><title>1</title><title>2</title></titleInfo></mods>")
        @mods_rec.alternative_titles.should == ['12']
      end
      it "should not get an alternative title if type attribute is absent from titleInfo" do
        @mods_rec.from_str("<mods #{@ns_decl}><titleInfo><title>ta da!</title></titleInfo></mods>")
        @mods_rec.alternative_titles.should == []
      end
      it "should not get an alternative title if type attribute from titleInfo is not 'alternative'" do
        @mods_rec.from_str("<mods #{@ns_decl}><titleInfo type='uniform'><title>ta da!</title></titleInfo></mods>")
        @mods_rec.alternative_titles.should == []
      end
      # note that Mods::Record.alternative_title tests are in record_spec
    end
  end # WITH namespaces
  
  context "WITHOUT namespaces" do
    
    it "should recognize type attribute on titleInfo element" do
      Mods::TitleInfo::TYPES.each { |t|
        @mods_rec.from_str("<mods><titleInfo type='#{t}'>hi</titleInfo></mods>", false)
        @mods_rec.title_info.type_at.should == [t]
      }
    end
    it "should recognize subelements" do
      Mods::TitleInfo::CHILD_ELEMENTS.each { |e|
        @mods_rec.from_str("<mods><titleInfo><#{e}>oofda</#{e}></titleInfo></mods>", false)
        @mods_rec.title_info.send(e).text.should == 'oofda'
      }
    end

    context "short_title" do
      it "should start with nonSort element" do
        @mods_rec.from_str("<mods><titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo></mods>", false)
        @mods_rec.title_info.short_title.should == ["The Jerk"]
      end
      it "should not include subtitle" do
        @mods_rec.from_str("<mods><titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo></mods>", false)
        @mods_rec.title_info.short_title.should == ["The Jerk"]
      end
      it "Mods::Record.short_titles convenience method should return an Array (multiple titles are legal in Mods)" do
        @mods_rec.from_str("<mods><titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo><titleInfo><title>Joke</title></titleInfo></mods>", false)
        @mods_rec.short_titles.should == ["The Jerk", "Joke"]
      end
      it "should not include alternative titles" do
        @mods_rec.from_str("<mods><titleInfo type='alternative'><title>ta da!</title></titleInfo></mods>", false)
        @mods_rec.short_titles.should_not include("ta da!")
        @mods_rec.from_str("<mods><titleInfo type='alternative'><title>1</title></titleInfo><titleInfo><title>2</title></titleInfo></mods>", false)
        @mods_rec.short_titles.should == ['2']
      end
      # note that Mods::Record.short_title tests are in record_spec
    end

    context "full_title" do
      it "should start with nonSort element" do
        @mods_rec.from_str("<mods><titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo></mods>", false)
        @mods_rec.title_info.full_title.should == ["The Jerk"]
      end
      it "should include subtitle" do
        @mods_rec.from_str("<mods><titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo></mods>", false)
        @mods_rec.title_info.full_title.should == ["The Jerk A Tale of Tourettes"]
      end
      it "Mods::Record.full_titles convenience method should return an Array (multiple titles are legal in Mods)" do
        @mods_rec.from_str("<mods><titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo><titleInfo><title>Joke</title></titleInfo></mods>", false)
        @mods_rec.full_titles.should == ["The Jerk", "Joke"]
      end
      # note that Mods::Record.full_title tests are in record_spec
    end

    context "sort_title" do
      it "should skip nonSort element" do
        @mods_rec.from_str("<mods><titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo></mods>", false)
        @mods_rec.title_info.sort_title.should == ["Jerk"]
      end
      it "should contain title and subtitle" do
        @mods_rec.from_str("<mods><titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo></mods>", false)
        @mods_rec.title_info.sort_title.should == ["Jerk A Tale of Tourettes"]
      end
      it "should be an alternative title if there are no other choices" do
        @mods_rec.from_str("<mods><titleInfo type='alternative'><title>1</title></titleInfo></mods>", false)
        @mods_rec.title_info.sort_title.should == ['1']
      end
      it "should not be an alternative title if there are other choices" do
        @mods_rec.from_str("<mods><titleInfo type='alternative'><title>1</title></titleInfo><titleInfo><title>2</title></titleInfo></mods>", false)
        @mods_rec.title_info.sort_title.should == ['2']
        @mods_rec.sort_title.should == '2'
      end
      it "should have a configurable delimiter between title and subtitle" do
        m = Mods::Record.new(' : ')
        m.from_str("<mods><titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo></mods>", false)
        m.title_info.sort_title.should == ["Jerk : A Tale of Tourettes"]
      end
      context "Mods::Record.sort_title convenience method" do
        it "convenience method sort_title in Mods::Record should return a string" do
          @mods_rec.from_str("<mods><titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo></mods>", false)
          @mods_rec.sort_title.should == "Jerk A Tale of Tourettes"
        end
      end
      # note that Mods::Record.sort_title tests are in record_spec
    end

    context "alternative_title" do
      it "should get an alternative title, if it exists" do
        @mods_rec.from_str("<mods><titleInfo type='alternative'><title>ta da!</title></titleInfo></mods>", false)
        @mods_rec.title_info.alternative_title.should == ["ta da!"]
      end
      it "Mods::Record.alternative_titles convenience method for getting an Array of alternative titles when there are multiple elements" do
        @mods_rec.from_str("<mods><titleInfo type='alternative'><title>1</title></titleInfo><titleInfo type='alternative'><title>2</title></titleInfo></mods>", false)
        @mods_rec.alternative_titles.should == ['1', '2']
        @mods_rec.from_str("<mods><titleInfo type='alternative'><title>1</title><title>2</title></titleInfo></mods>", false)
        @mods_rec.alternative_titles.should == ['12']
      end
      it "should not get an alternative title if type attribute is absent from titleInfo" do
        @mods_rec.from_str("<mods><titleInfo><title>ta da!</title></titleInfo></mods>", false)
        @mods_rec.alternative_titles.should == []
      end
      it "should not get an alternative title if type attribute from titleInfo is not 'alternative'" do
        @mods_rec.from_str("<mods><titleInfo type='uniform'><title>ta da!</title></titleInfo></mods>", false)
        @mods_rec.alternative_titles.should == []
      end
      # note that Mods::Record.alternative_title tests are in record_spec
    end
  end # WITHOUT namespaces
      
end