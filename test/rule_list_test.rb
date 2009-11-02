require 'test_helper'

class RuleListTest < Test::Unit::TestCase

  def setup
    @list = DomainName::RuleList.new
  end


  def test_initialize
    assert_instance_of DomainName::RuleList, @list
    assert_equal 0, @list.length
  end


  def test_equality_with_self
    list = DomainName::RuleList.new
    assert_equal list, list
  end

  def test_equality_with_internals
    rule = DomainName::Rule.new("com")
    assert_equal DomainName::RuleList.new.add(rule), DomainName::RuleList.new.add(rule)
  end


  def test_add
    assert_equal @list, @list.add(DomainName::Rule.new(""))
    assert_equal @list, @list <<  DomainName::Rule.new("")
    assert_equal 2, @list.length
  end

  def test_empty?
    assert  @list.empty?
    @list.add(DomainName::Rule.new(""))
    assert !@list.empty?
  end

  def test_size
    assert_equal 0, @list.length
    assert_equal @list, @list.add(DomainName::Rule.new(""))
    assert_equal 1, @list.length
  end

  def test_clear
    assert_equal 0, @list.length
    assert_equal @list, @list.add(DomainName::Rule.new(""))
    assert_equal 1, @list.length
    assert_equal @list, @list.clear
    assert_equal 0, @list.length
  end


  def test_find
    @list = DomainName::RuleList.parse(<<EOS)
// com : http://en.wikipedia.org/wiki/.com
com

// uk : http://en.wikipedia.org/wiki/.uk
*.uk
*.sch.uk
!bl.uk
!british-library.uk
EOS
    assert_equal DomainName::Rule.new("com"),  @list.find(domain_name("google.com"))
    assert_equal DomainName::Rule.new("com"),  @list.find(domain_name("foo.google.com"))
    assert_equal DomainName::Rule.new("*.uk"), @list.find(domain_name("google.uk"))
    assert_equal DomainName::Rule.new("*.uk"), @list.find(domain_name("google.co.uk"))
    assert_equal DomainName::Rule.new("*.uk"), @list.find(domain_name("foo.google.co.uk"))
    assert_equal DomainName::Rule.new("!british-library.uk"), @list.find(domain_name("british-library.uk"))
    assert_equal DomainName::Rule.new("!british-library.uk"), @list.find(domain_name("foo.british-library.uk"))
  end

  def test_select
    @list = DomainName::RuleList.parse(<<EOS)
// com : http://en.wikipedia.org/wiki/.com
com

// uk : http://en.wikipedia.org/wiki/.uk
*.uk
*.sch.uk
!bl.uk
!british-library.uk
EOS
    assert_equal 2, @list.select(domain_name("british-library.uk")).size
  end


  def test_self_default_getter
    assert_equal     nil, DomainName::RuleList.send(:class_variable_get, :"@@default")
    DomainName::RuleList.default
    assert_not_equal nil, DomainName::RuleList.send(:class_variable_get, :"@@default")
  end

  def test_self_default_setter
    DomainName::RuleList.default
    assert_not_equal nil, DomainName::RuleList.send(:class_variable_get, :"@@default")
    DomainName::RuleList.default = nil
    assert_equal     nil, DomainName::RuleList.send(:class_variable_get, :"@@default")
  end

  def test_self_clear
    DomainName::RuleList.default
    assert_not_equal nil, DomainName::RuleList.send(:class_variable_get, :"@@default")
    DomainName::RuleList.clear
    assert_equal     nil, DomainName::RuleList.send(:class_variable_get, :"@@default")
  end

  def test_self_reload
    DomainName::RuleList.default
    DomainName::RuleList.expects(:default_definition).returns("")
    DomainName::RuleList.reload
    assert_equal DomainName::RuleList.new, DomainName::RuleList.default
  end

  def test_self_parse
    input = <<EOS
// ***** BEGIN LICENSE BLOCK *****
// Version: MPL 1.1/GPL 2.0/LGPL 2.1
//
// The contents of this file are subject to the Mozilla Public License Version
// 1.1 (the "License"); you may not use this file except in compliance with
// the License. You may obtain a copy of the License at
// http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
// for the specific language governing rights and limitations under the
// License.
//
// The Original Code is the Public Suffix List.
//
// The Initial Developer of the Original Code is
// Jo Hermans <jo.hermans@gmail.com>.
// Portions created by the Initial Developer are Copyright (C) 2007
// the Initial Developer. All Rights Reserved.
//
// Contributor(s):
//   Ruben Arakelyan <ruben@wackomenace.co.uk>
//   Gervase Markham <gerv@gerv.net>
//   Pamela Greene <pamg.bugs@gmail.com>
//   David Triendl <david@triendl.name>
//   The kind representatives of many TLD registries
//
// Alternatively, the contents of this file may be used under the terms of
// either the GNU General Public License Version 2 or later (the "GPL"), or
// the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
// in which case the provisions of the GPL or the LGPL are applicable instead
// of those above. If you wish to allow use of your version of this file only
// under the terms of either the GPL or the LGPL, and not to allow others to
// use your version of this file under the terms of the MPL, indicate your
// decision by deleting the provisions above and replace them with the notice
// and other provisions required by the GPL or the LGPL. If you do not delete
// the provisions above, a recipient may use your version of this file under
// the terms of any one of the MPL, the GPL or the LGPL.
//
// ***** END LICENSE BLOCK *****

// ac : http://en.wikipedia.org/wiki/.ac
ac
com.ac

// ad : http://en.wikipedia.org/wiki/.ad
ad

// ar : http://en.wikipedia.org/wiki/.ar
*.ar
!congresodelalengua3.ar
EOS
    expected = []
    list = DomainName::RuleList.parse(input)

    assert_instance_of DomainName::RuleList, list
    assert_equal 5, list.length
    assert_equal %w(ac com.ac ad *.ar !congresodelalengua3.ar).map { |name| DomainName::Rule.new(name) }, list.to_a
  end

end