# Perl-to-Python
This code can translate Perl code to Python code in some basic function.
This is not useful in full function of Python.


Usage:
./plpy.pl subset0/hello_world.pl > hello_world.py

example:

//before                                               //after
#!/usr/bin/perl -w                                     #!/usr/local/bin/python3.5 -u
                               ----------->
print "hello world\n";                                 print("hello world")

