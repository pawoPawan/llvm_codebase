//===-- FileSpecTest.cpp --------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "gtest/gtest.h"

#include "lldb/Utility/FileSpec.h"

using namespace lldb_private;

static FileSpec PosixSpec(llvm::StringRef path) {
  return FileSpec(path, FileSpec::Style::posix);
}

static FileSpec WindowsSpec(llvm::StringRef path) {
  return FileSpec(path, FileSpec::Style::windows);
}

TEST(FileSpecTest, FileAndDirectoryComponents) {
  FileSpec fs_posix("/foo/bar", FileSpec::Style::posix);
  EXPECT_STREQ("/foo/bar", fs_posix.GetPath().c_str());
  EXPECT_STREQ("/foo", fs_posix.GetDirectory().GetCString());
  EXPECT_STREQ("bar", fs_posix.GetFilename().GetCString());

  FileSpec fs_windows("F:\\bar", FileSpec::Style::windows);
  EXPECT_STREQ("F:\\bar", fs_windows.GetPath().c_str());
  // EXPECT_STREQ("F:\\", fs_windows.GetDirectory().GetPath().c_str()); // It returns
  // "F:/"
  EXPECT_STREQ("bar", fs_windows.GetFilename().GetCString());

  FileSpec fs_posix_root("/", FileSpec::Style::posix);
  EXPECT_STREQ("/", fs_posix_root.GetPath().c_str());
  EXPECT_EQ(nullptr, fs_posix_root.GetDirectory().GetCString());
  EXPECT_STREQ("/", fs_posix_root.GetFilename().GetCString());

  FileSpec fs_net_drive("//net", FileSpec::Style::posix);
  EXPECT_STREQ("//net", fs_net_drive.GetPath().c_str());
  EXPECT_EQ(nullptr, fs_net_drive.GetDirectory().GetCString());
  EXPECT_STREQ("//net", fs_net_drive.GetFilename().GetCString());

  FileSpec fs_net_root("//net/", FileSpec::Style::posix);
  EXPECT_STREQ("//net/", fs_net_root.GetPath().c_str());
  EXPECT_STREQ("//net", fs_net_root.GetDirectory().GetCString());
  EXPECT_STREQ("/", fs_net_root.GetFilename().GetCString());

  FileSpec fs_windows_drive("F:", FileSpec::Style::windows);
  EXPECT_STREQ("F:", fs_windows_drive.GetPath().c_str());
  EXPECT_EQ(nullptr, fs_windows_drive.GetDirectory().GetCString());
  EXPECT_STREQ("F:", fs_windows_drive.GetFilename().GetCString());

  FileSpec fs_windows_root("F:\\", FileSpec::Style::windows);
  EXPECT_STREQ("F:\\", fs_windows_root.GetPath().c_str());
  EXPECT_STREQ("F:", fs_windows_root.GetDirectory().GetCString());
  // EXPECT_STREQ("\\", fs_windows_root.GetFilename().GetCString()); // It
  // returns "/"

  FileSpec fs_posix_long("/foo/bar/baz", FileSpec::Style::posix);
  EXPECT_STREQ("/foo/bar/baz", fs_posix_long.GetPath().c_str());
  EXPECT_STREQ("/foo/bar", fs_posix_long.GetDirectory().GetCString());
  EXPECT_STREQ("baz", fs_posix_long.GetFilename().GetCString());

  FileSpec fs_windows_long("F:\\bar\\baz", FileSpec::Style::windows);
  EXPECT_STREQ("F:\\bar\\baz", fs_windows_long.GetPath().c_str());
  // EXPECT_STREQ("F:\\bar", fs_windows_long.GetDirectory().GetCString()); // It
  // returns "F:/bar"
  EXPECT_STREQ("baz", fs_windows_long.GetFilename().GetCString());

  FileSpec fs_posix_trailing_slash("/foo/bar/", FileSpec::Style::posix);
  EXPECT_STREQ("/foo/bar", fs_posix_trailing_slash.GetPath().c_str());
  EXPECT_STREQ("/foo", fs_posix_trailing_slash.GetDirectory().GetCString());
  EXPECT_STREQ("bar", fs_posix_trailing_slash.GetFilename().GetCString());

  FileSpec fs_windows_trailing_slash("F:\\bar\\", FileSpec::Style::windows);
  EXPECT_STREQ("F:\\bar", fs_windows_trailing_slash.GetPath().c_str());
  EXPECT_STREQ("bar", fs_windows_trailing_slash.GetFilename().GetCString());
}

TEST(FileSpecTest, AppendPathComponent) {
  FileSpec fs_posix("/foo", FileSpec::Style::posix);
  fs_posix.AppendPathComponent("bar");
  EXPECT_STREQ("/foo/bar", fs_posix.GetPath().c_str());
  EXPECT_STREQ("/foo", fs_posix.GetDirectory().GetCString());
  EXPECT_STREQ("bar", fs_posix.GetFilename().GetCString());

  FileSpec fs_posix_2("/foo", FileSpec::Style::posix);
  fs_posix_2.AppendPathComponent("//bar/baz");
  EXPECT_STREQ("/foo/bar/baz", fs_posix_2.GetPath().c_str());
  EXPECT_STREQ("/foo/bar", fs_posix_2.GetDirectory().GetCString());
  EXPECT_STREQ("baz", fs_posix_2.GetFilename().GetCString());

  FileSpec fs_windows("F:\\bar", FileSpec::Style::windows);
  fs_windows.AppendPathComponent("baz");
  EXPECT_STREQ("F:\\bar\\baz", fs_windows.GetPath().c_str());
  // EXPECT_STREQ("F:\\bar", fs_windows.GetDirectory().GetCString()); // It
  // returns "F:/bar"
  EXPECT_STREQ("baz", fs_windows.GetFilename().GetCString());

  FileSpec fs_posix_root("/", FileSpec::Style::posix);
  fs_posix_root.AppendPathComponent("bar");
  EXPECT_STREQ("/bar", fs_posix_root.GetPath().c_str());
  EXPECT_STREQ("/", fs_posix_root.GetDirectory().GetCString());
  EXPECT_STREQ("bar", fs_posix_root.GetFilename().GetCString());

  FileSpec fs_windows_root("F:\\", FileSpec::Style::windows);
  fs_windows_root.AppendPathComponent("bar");
  EXPECT_STREQ("F:\\bar", fs_windows_root.GetPath().c_str());
  // EXPECT_STREQ("F:\\", fs_windows_root.GetDirectory().GetCString()); // It
  // returns "F:/"
  EXPECT_STREQ("bar", fs_windows_root.GetFilename().GetCString());
}

TEST(FileSpecTest, CopyByAppendingPathComponent) {
  FileSpec fs = PosixSpec("/foo").CopyByAppendingPathComponent("bar");
  EXPECT_STREQ("/foo/bar", fs.GetPath().c_str());
  EXPECT_STREQ("/foo", fs.GetDirectory().GetCString());
  EXPECT_STREQ("bar", fs.GetFilename().GetCString());
}

TEST(FileSpecTest, PrependPathComponent) {
  FileSpec fs_posix("foo", FileSpec::Style::posix);
  fs_posix.PrependPathComponent("/bar");
  EXPECT_STREQ("/bar/foo", fs_posix.GetPath().c_str());

  FileSpec fs_posix_2("foo/bar", FileSpec::Style::posix);
  fs_posix_2.PrependPathComponent("/baz");
  EXPECT_STREQ("/baz/foo/bar", fs_posix_2.GetPath().c_str());

  FileSpec fs_windows("baz", FileSpec::Style::windows);
  fs_windows.PrependPathComponent("F:\\bar");
  EXPECT_STREQ("F:\\bar\\baz", fs_windows.GetPath().c_str());

  FileSpec fs_posix_root("bar", FileSpec::Style::posix);
  fs_posix_root.PrependPathComponent("/");
  EXPECT_STREQ("/bar", fs_posix_root.GetPath().c_str());

  FileSpec fs_windows_root("bar", FileSpec::Style::windows);
  fs_windows_root.PrependPathComponent("F:\\");
  EXPECT_STREQ("F:\\bar", fs_windows_root.GetPath().c_str());
}

TEST(FileSpecTest, EqualSeparator) {
  EXPECT_EQ(WindowsSpec("C:\\foo\\bar"), WindowsSpec("C:/foo/bar"));
}

TEST(FileSpecTest, EqualDotsWindows) {
  std::pair<const char *, const char *> tests[] = {
      {R"(C:\foo\bar\baz)", R"(C:\foo\foo\..\bar\baz)"},
      {R"(C:\bar\baz)", R"(C:\foo\..\bar\baz)"},
      {R"(C:\bar\baz)", R"(C:/foo/../bar/baz)"},
      {R"(C:/bar/baz)", R"(C:\foo\..\bar\baz)"},
      {R"(C:\bar)", R"(C:\foo\..\bar)"},
      {R"(C:\foo\bar)", R"(C:\foo\.\bar)"},
      {R"(C:\foo\bar)", R"(C:\foo\bar\.)"},
  };

  for (const auto &test : tests) {
    SCOPED_TRACE(llvm::Twine(test.first) + " <=> " + test.second);
    EXPECT_EQ(WindowsSpec(test.first), WindowsSpec(test.second));
  }
}

TEST(FileSpecTest, EqualDotsPosix) {
  std::pair<const char *, const char *> tests[] = {
      {R"(/foo/bar/baz)", R"(/foo/foo/../bar/baz)"},
      {R"(/bar/baz)", R"(/foo/../bar/baz)"},
      {R"(/bar)", R"(/foo/../bar)"},
      {R"(/foo/bar)", R"(/foo/./bar)"},
      {R"(/foo/bar)", R"(/foo/bar/.)"},
  };

  for (const auto &test : tests) {
    SCOPED_TRACE(llvm::Twine(test.first) + " <=> " + test.second);
    EXPECT_EQ(PosixSpec(test.first), PosixSpec(test.second));
  }
}

TEST(FileSpecTest, EqualDotsPosixRoot) {
  std::pair<const char *, const char *> tests[] = {
      {R"(/)", R"(/..)"},
      {R"(/)", R"(/.)"},
      {R"(/)", R"(/foo/..)"},
  };

  for (const auto &test : tests) {
    SCOPED_TRACE(llvm::Twine(test.first) + " <=> " + test.second);
    EXPECT_EQ(PosixSpec(test.first), PosixSpec(test.second));
  }
}

TEST(FileSpecTest, GuessPathStyle) {
  EXPECT_EQ(FileSpec::Style::posix, FileSpec::GuessPathStyle("/foo/bar.txt"));
  EXPECT_EQ(FileSpec::Style::posix, FileSpec::GuessPathStyle("//net/bar.txt"));
  EXPECT_EQ(FileSpec::Style::windows,
            FileSpec::GuessPathStyle(R"(C:\foo.txt)"));
  EXPECT_EQ(FileSpec::Style::windows,
            FileSpec::GuessPathStyle(R"(C:/foo.txt)"));
  EXPECT_EQ(FileSpec::Style::windows,
            FileSpec::GuessPathStyle(R"(\\net\foo.txt)"));
  EXPECT_EQ(FileSpec::Style::windows, FileSpec::GuessPathStyle(R"(Z:\)"));
  EXPECT_EQ(FileSpec::Style::windows, FileSpec::GuessPathStyle(R"(Z:/)"));
  EXPECT_EQ(std::nullopt, FileSpec::GuessPathStyle("foo.txt"));
  EXPECT_EQ(std::nullopt, FileSpec::GuessPathStyle("foo/bar.txt"));
  EXPECT_EQ(std::nullopt, FileSpec::GuessPathStyle("Z:"));
}

TEST(FileSpecTest, GetPath) {
  std::pair<const char *, const char *> posix_tests[] = {
      {"/foo/.././bar", "/bar"},
      {"/foo/./../bar", "/bar"},
      {"/foo/../bar", "/bar"},
      {"/foo/./bar", "/foo/bar"},
      {"/foo/..", "/"},
      {"/foo/.", "/foo"},
      {"/foo//bar", "/foo/bar"},
      {"/foo//bar/baz", "/foo/bar/baz"},
      {"/foo//bar/./baz", "/foo/bar/baz"},
      {"/./foo", "/foo"},
      {"/", "/"},
      {"//", "/"},
      {"//net", "//net"},
      {"/..", "/"},
      {"/.", "/"},
      {"..", ".."},
      {".", "."},
      {"../..", "../.."},
      {"foo/..", "."},
      {"foo/../bar", "bar"},
      {"../foo/..", ".."},
      {"./foo", "foo"},
      {"././foo", "foo"},
      {"../foo", "../foo"},
      {"../../foo", "../../foo"},
  };
  for (auto test : posix_tests) {
    SCOPED_TRACE(llvm::Twine("test.first = ") + test.first);
    EXPECT_EQ(test.second, PosixSpec(test.first).GetPath());
  }

  std::pair<const char *, const char *> windows_tests[] = {
      {R"(c:\bar\..\bar)", R"(c:\bar)"},
      {R"(c:\bar\.\bar)", R"(c:\bar\bar)"},
      {R"(c:\bar\..)", R"(c:\)"},
      {R"(c:\bar\.)", R"(c:\bar)"},
      {R"(c:\.\bar)", R"(c:\bar)"},
      {R"(\)", R"(\)"},
      {R"(\\)", R"(\)"},
      {R"(\\net)", R"(\\net)"},
      {R"(c:\..)", R"(c:\)"},
      {R"(c:\.)", R"(c:\)"},
      {R"(\..)", R"(\)"},
      //      {R"(c:..)", R"(c:..)"},
      {R"(..)", R"(..)"},
      {R"(.)", R"(.)"},
      {R"(c:..\..)", R"(c:)"},
      {R"(..\..)", R"(..\..)"},
      {R"(foo\..)", R"(.)"},
      {R"(foo\..\bar)", R"(bar)"},
      {R"(..\foo\..)", R"(..)"},
      {R"(.\foo)", R"(foo)"},
      {R"(.\.\foo)", R"(foo)"},
      {R"(..\foo)", R"(..\foo)"},
      {R"(..\..\foo)", R"(..\..\foo)"},
  };
  for (auto test : windows_tests) {
    SCOPED_TRACE(llvm::Twine("test.first = ") + test.first);
    EXPECT_EQ(test.second, WindowsSpec(test.first).GetPath());
  }
}

TEST(FileSpecTest, FormatFileSpec) {
  auto win = FileSpec::Style::windows;

  FileSpec F;
  EXPECT_EQ("(empty)", llvm::formatv("{0}", F).str());
  EXPECT_EQ("(empty)", llvm::formatv("{0:D}", F).str());
  EXPECT_EQ("(empty)", llvm::formatv("{0:F}", F).str());

  F = FileSpec("C:\\foo\\bar.txt", win);
  EXPECT_EQ("C:\\foo\\bar.txt", llvm::formatv("{0}", F).str());
  EXPECT_EQ("C:\\foo\\", llvm::formatv("{0:D}", F).str());
  EXPECT_EQ("bar.txt", llvm::formatv("{0:F}", F).str());

  F = FileSpec("foo\\bar.txt", win);
  EXPECT_EQ("foo\\bar.txt", llvm::formatv("{0}", F).str());
  EXPECT_EQ("foo\\", llvm::formatv("{0:D}", F).str());
  EXPECT_EQ("bar.txt", llvm::formatv("{0:F}", F).str());

  F = FileSpec("foo", win);
  EXPECT_EQ("foo", llvm::formatv("{0}", F).str());
  EXPECT_EQ("foo", llvm::formatv("{0:F}", F).str());
  EXPECT_EQ("(empty)", llvm::formatv("{0:D}", F).str());
}

TEST(FileSpecTest, IsRelative) {
  llvm::StringRef not_relative[] = {
    "/",
    "/a",
    "/a/",
    "/a/b",
    "/a/b/",
    "//",
    "//a/",
    "//a/b",
    "//a/b/",
    "~",
    "~/",
    "~/a",
    "~/a/",
    "~/a/b",
    "~/a/b/",
    "/foo/.",
    "/foo/..",
    "/foo/../",
    "/foo/../.",
  };
  for (const auto &path: not_relative) {
    SCOPED_TRACE(path);
    EXPECT_FALSE(PosixSpec(path).IsRelative());
  }
  llvm::StringRef is_relative[] = {
    ".",
    "./",
    ".///",
    "a",
    "./a",
    "./a/",
    "./a/",
    "./a/b",
    "./a/b/",
    "../foo",
    "foo/bar.c",
    "./foo/bar.c"
  };
  for (const auto &path: is_relative) {
    SCOPED_TRACE(path);
    EXPECT_TRUE(PosixSpec(path).IsRelative());
  }
}

TEST(FileSpecTest, RemoveLastPathComponent) {
  FileSpec fs_posix("/foo/bar/baz", FileSpec::Style::posix);
  EXPECT_STREQ("/foo/bar/baz", fs_posix.GetPath().c_str());
  EXPECT_TRUE(fs_posix.RemoveLastPathComponent());
  EXPECT_STREQ("/foo/bar", fs_posix.GetPath().c_str());
  EXPECT_TRUE(fs_posix.RemoveLastPathComponent());
  EXPECT_STREQ("/foo", fs_posix.GetPath().c_str());
  EXPECT_TRUE(fs_posix.RemoveLastPathComponent());
  EXPECT_STREQ("/", fs_posix.GetPath().c_str());
  EXPECT_FALSE(fs_posix.RemoveLastPathComponent());
  EXPECT_STREQ("/", fs_posix.GetPath().c_str());

  FileSpec fs_posix_relative("./foo/bar/baz", FileSpec::Style::posix);
  EXPECT_STREQ("foo/bar/baz", fs_posix_relative.GetPath().c_str());
  EXPECT_TRUE(fs_posix_relative.RemoveLastPathComponent());
  EXPECT_STREQ("foo/bar", fs_posix_relative.GetPath().c_str());
  EXPECT_TRUE(fs_posix_relative.RemoveLastPathComponent());
  EXPECT_STREQ("foo", fs_posix_relative.GetPath().c_str());
  EXPECT_FALSE(fs_posix_relative.RemoveLastPathComponent());
  EXPECT_STREQ("foo", fs_posix_relative.GetPath().c_str());

  FileSpec fs_posix_relative2("./", FileSpec::Style::posix);
  EXPECT_STREQ(".", fs_posix_relative2.GetPath().c_str());
  EXPECT_FALSE(fs_posix_relative2.RemoveLastPathComponent());
  EXPECT_STREQ(".", fs_posix_relative2.GetPath().c_str());
  EXPECT_FALSE(fs_posix_relative.RemoveLastPathComponent());
  EXPECT_STREQ(".", fs_posix_relative2.GetPath().c_str());

  FileSpec fs_windows("C:\\foo\\bar\\baz", FileSpec::Style::windows);
  EXPECT_STREQ("C:\\foo\\bar\\baz", fs_windows.GetPath().c_str());
  EXPECT_TRUE(fs_windows.RemoveLastPathComponent());
  EXPECT_STREQ("C:\\foo\\bar", fs_windows.GetPath().c_str());
  EXPECT_TRUE(fs_windows.RemoveLastPathComponent());
  EXPECT_STREQ("C:\\foo", fs_windows.GetPath().c_str());
  EXPECT_TRUE(fs_windows.RemoveLastPathComponent());
  EXPECT_STREQ("C:\\", fs_windows.GetPath().c_str());
  EXPECT_TRUE(fs_windows.RemoveLastPathComponent());
  EXPECT_STREQ("C:", fs_windows.GetPath().c_str());
  EXPECT_FALSE(fs_windows.RemoveLastPathComponent());
  EXPECT_STREQ("C:", fs_windows.GetPath().c_str());
}

TEST(FileSpecTest, Equal) {
  auto Eq = [](const char *a, const char *b, bool full) {
    return FileSpec::Equal(PosixSpec(a), PosixSpec(b), full);
  };
  EXPECT_TRUE(Eq("/foo/bar", "/foo/bar", true));
  EXPECT_TRUE(Eq("/foo/bar", "/foo/bar", false));

  EXPECT_FALSE(Eq("/foo/bar", "/foo/baz", true));
  EXPECT_FALSE(Eq("/foo/bar", "/foo/baz", false));

  EXPECT_FALSE(Eq("/bar/foo", "/baz/foo", true));
  EXPECT_FALSE(Eq("/bar/foo", "/baz/foo", false));

  EXPECT_FALSE(Eq("/bar/foo", "foo", true));
  EXPECT_TRUE(Eq("/bar/foo", "foo", false));

  EXPECT_FALSE(Eq("foo", "/bar/foo", true));
  EXPECT_TRUE(Eq("foo", "/bar/foo", false));
}

TEST(FileSpecTest, Match) {
  auto Match = [](const char *pattern, const char *file) {
    return FileSpec::Match(PosixSpec(pattern), PosixSpec(file));
  };
  EXPECT_TRUE(Match("/foo/bar", "/foo/bar"));
  EXPECT_FALSE(Match("/foo/bar", "/oof/bar"));
  EXPECT_FALSE(Match("/foo/bar", "/foo/baz"));
  EXPECT_FALSE(Match("/foo/bar", "bar"));
  EXPECT_FALSE(Match("/foo/bar", ""));

  EXPECT_TRUE(Match("bar", "/foo/bar"));
  EXPECT_FALSE(Match("bar", "/foo/baz"));
  EXPECT_TRUE(Match("bar", "bar"));
  EXPECT_FALSE(Match("bar", "baz"));
  EXPECT_FALSE(Match("bar", ""));

  EXPECT_TRUE(Match("", "/foo/bar"));
  EXPECT_TRUE(Match("", ""));

}

TEST(FileSpecTest, TestAbsoluteCaching) {
  // Test that if we modify a path that we recalculate if a path is relative
  // or absolute correctly. The test below calls set accessors and functions
  // that change the path and verifies that the FileSpec::IsAbsolute() returns
  // the correct value.
  FileSpec file = PosixSpec("/tmp/a");
  EXPECT_TRUE(file.IsAbsolute());
  file.ClearDirectory();
  EXPECT_FALSE(file.IsAbsolute());
  file.SetDirectory("/tmp");
  EXPECT_TRUE(file.IsAbsolute());
  file.SetDirectory(".");
  EXPECT_FALSE(file.IsAbsolute());
  file.SetPath("/log.txt");
  EXPECT_TRUE(file.IsAbsolute());
  file.RemoveLastPathComponent();
  EXPECT_TRUE(file.IsAbsolute());
  file.ClearFilename();
  EXPECT_FALSE(file.IsAbsolute());
  file.AppendPathComponent("foo.txt");
  EXPECT_FALSE(file.IsAbsolute());
  file.PrependPathComponent("/tmp");
  EXPECT_TRUE(file.IsAbsolute());
}

TEST(FileSpecTest, TestFileNameExtensions) {
  FileSpec dylib = PosixSpec("/tmp/foo.dylib");
  FileSpec exe = PosixSpec("/tmp/foo");
  FileSpec dSYM = PosixSpec("/tmp/foo.dSYM/");
  FileSpec just_dot = PosixSpec("/tmp/bar.");

  EXPECT_TRUE(dylib.GetFileNameExtension() == ".dylib");
  EXPECT_TRUE(exe.GetFileNameExtension() == llvm::StringRef());
  EXPECT_TRUE(dSYM.GetFileNameExtension() == ".dSYM");
  EXPECT_TRUE(just_dot.GetFileNameExtension() == ".");

  FileSpec dll = WindowsSpec("C:\\tmp\\foo.dll");
  FileSpec win_noext = WindowsSpec("C:\\tmp\\foo");

  EXPECT_TRUE(dll.GetFileNameExtension() == ".dll");
  EXPECT_TRUE(win_noext.GetFileNameExtension() == llvm::StringRef());
}

TEST(FileSpecTest, TestFileNameStrippingExtension) {
  FileSpec dylib = PosixSpec("/tmp/foo.dylib");
  FileSpec exe = PosixSpec("/tmp/foo");
  FileSpec just_dot = PosixSpec("/tmp/bar.");

  EXPECT_TRUE(dylib.GetFileNameStrippingExtension() == "foo");
  EXPECT_TRUE(exe.GetFileNameStrippingExtension() == "foo");
  EXPECT_TRUE(just_dot.GetFileNameStrippingExtension() == "bar");

  FileSpec dll = WindowsSpec("C:\\tmp\\foo.dll");
  FileSpec win_noext = WindowsSpec("C:\\tmp\\foo");

  EXPECT_TRUE(dll.GetFileNameStrippingExtension() == "foo");
  EXPECT_TRUE(win_noext.GetFileNameStrippingExtension() == "foo");
}

TEST(FileSpecTest, TestIsSourceImplementationFile) {
  FileSpec c_src = PosixSpec("/tmp/foo.c");
  FileSpec txt_file = PosixSpec("/tmp/foo.txt");
  FileSpec executable = PosixSpec("/tmp/foo");
  FileSpec just_dot = PosixSpec("/tmp/bar.");

  EXPECT_TRUE(c_src.IsSourceImplementationFile());
  EXPECT_FALSE(txt_file.IsSourceImplementationFile());
  EXPECT_FALSE(executable.IsSourceImplementationFile());
  EXPECT_FALSE(just_dot.IsSourceImplementationFile());

  FileSpec cpp_src = WindowsSpec("C:\\tmp\\foo.cpp");
  FileSpec dll = WindowsSpec("C:\\tmp\\foo.dll");
  FileSpec win_noext = WindowsSpec("C:\\tmp\\foo");
  FileSpec exe = WindowsSpec("C:\\tmp\\foo.exe");

  EXPECT_TRUE(cpp_src.IsSourceImplementationFile());
  EXPECT_FALSE(dll.IsSourceImplementationFile());
  EXPECT_FALSE(win_noext.IsSourceImplementationFile());
  EXPECT_FALSE(exe.IsSourceImplementationFile());
}

TEST(FileSpecTest, TestGetComponents) {
  std::pair<llvm::StringRef, std::vector<llvm::StringRef>> PosixTests[] = {
      {"/", {}},
      {"/foo", {"foo"}},
      {"/foo/", {"foo"}},
      {"/foo/bar", {"foo", "bar"}},
      {"/llvm-project/lldb/unittests/Utility/FileSpecTest.cpp",
       {"llvm-project", "lldb", "unittests", "Utility", "FileSpecTest.cpp"}},
  };

  for (const auto &pair : PosixTests) {
    FileSpec file_spec = PosixSpec(pair.first);
    EXPECT_EQ(file_spec.GetComponents(), pair.second);
  }

  std::pair<llvm::StringRef, std::vector<llvm::StringRef>> WindowsTests[] = {
      {"C:\\", {"C:"}},
      {"C:\\Windows\\", {"C:", "Windows"}},
      {"C:\\Windows\\System32", {"C:", "Windows", "System32"}},
      {"C:\\llvm-project\\lldb\\unittests\\Utility\\FileSpecTest.cpp",
       {"C:", "llvm-project", "lldb", "unittests", "Utility",
        "FileSpecTest.cpp"}},
  };

  for (const auto &pair : WindowsTests) {
    FileSpec file_spec = WindowsSpec(pair.first);
    EXPECT_EQ(file_spec.GetComponents(), pair.second);
  }
}

TEST(FileSpecTest, TestChecksum) {
  Checksum checksum({0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15});
  FileSpec file_spec("/foo/bar", FileSpec::Style::posix, checksum);
  EXPECT_TRUE(static_cast<bool>(file_spec.GetChecksum()));
  EXPECT_EQ(file_spec.GetChecksum(), checksum);

  FileSpec copy = file_spec;

  EXPECT_TRUE(static_cast<bool>(copy.GetChecksum()));
  EXPECT_EQ(file_spec.GetChecksum(), copy.GetChecksum());
}
