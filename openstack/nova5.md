```
3.2.4 应用程序接口
　　一个应用程序对象是一个简单的接受两个参数的可调用对象，这里的对象并不是真的需要一个对象实例，一个函数、方法、类、或者带有 __call__ 方法的对象实例都可以用来做应用程序对象。应用程序对象必须可以多次被请求，实际上服务器/gateway(而非CGI)确实会产生这样的重复请求。
　　(注意：虽然我们把他叫做"应用程序"对象，但并不是说程序员要把WSGI当做API来调用，我们假定应用程序开发者仍然使用更高层面上的框架服务来开发应用程序，WSGI是提供给框架和服务器开发者使用的工具，并不打算直接对应用程序开发者提供支持)
　　这里有两个应用程序对象的示例，一个是函数，另一个是类:　　
    def simple_app(environ, start_response):
　　    """也许是最简单的应用程序对象"""
　　    status = \'200 OK\'
　　    response_headers = [(\'Content-type\',\'text/plain\')]
　　    start_response(status, response_headers)
　　    return [\'Hello world!n\']
　　class AppClass:
　　    """产生同样的输出，不过是使用一个类来实现
　　
　　    (注意: \'AppClass\' 在这里就是 "application" ,所以对它的调用会\'AppClass\'的一个实例,
　　    这个实例做为迭代器再返回"application callable"应该返回的那些值)
　　
　　    如果我们想使用 \'AppClass\' 的实例直接作为应用程序对象, 我们就必须实现 ``__call__`` 方法,
　　    外部通过调用这个方法来执行应用程序, 并且我们需要创建一个实例给服务器或gateway使用.
　　    """
　　
　　    def __init__(self, environ, start_response):
　　        self.environ = environ
　　        self.start = start_response
　　
　　    def __iter__(self):
　　        status = \'200 OK\'
　　        response_headers = [(\'Content-type\',\'text/plain\')]
　　        self.start(status, response_headers)
　　        yield "Hello world!n"
　　Django开发服务器使用的应用程序接口,django.core.handlers.WSGIHandler类.
　　class WSGIHandler(base.BaseHandler):
　　    initLock = Lock()
　　    request_class = WSGIRequest
　　
　　    def __call__(self, environ, start_response):
　　        ##############################
　　        # 暂时略过
　　        ##############################
　　        return response
　　 
3.2.5 服务器接口
　　服务器/gateway为每一个http客户端发来的请求都会请求应用程序可调用者一次。为了说明这里有一个CGI gateway，以一个获取应用程序对象的函数实现，请注意，这个例子拥有有限的错误处理，因为默认情况下没有被捕获的异常都会被输出到 sys.stderr并被服务器记录下来。
　　import os, sys
　　
　　def run_with_cgi(application):
　　
　　    environ = dict(os.environ.items())
　　    environ[\'wsgi.input\']        = sys.stdin
　　    environ[\'wsgi.errors\']       = sys.stderr
　　    environ[\'wsgi.version\']      = (1,0)
　　    environ[\'wsgi.multithread\']  = False
　　    environ[\'wsgi.multiprocess\'] = True
　　    environ[\'wsgi.run_once\']    = True
　　
　　    if environ.get(\'HTTPS\',\'off\') in (\'on\',\'1\'):
　　        environ[\'wsgi.url_scheme\'] = \'https\'
　　    else:
　　        environ[\'wsgi.url_scheme\'] = \'http\'
　　
　　    headers_set = []
　　    headers_sent = []
　　
　　    def write(data):
　　        if not headers_set:
　　             raise AssertionError("write() before start_response()")
　　
　　        elif not headers_sent:
　　             # Before the first output, send the stored headers
　　             status, response_headers = headers_sent[:] = headers_set
　　             sys.stdout.write(\'Status: %srn\' % status)
　　             for header in response_headers:
　　                 sys.stdout.write(\'%s: %srn\' % header)
　　             sys.stdout.write(\'rn\')
　　
　　        sys.stdout.write(data)
　　        sys.stdout.flush()
　　
　　    def start_response(status,response_headers,exc_info=None):
　　        if exc_info:
　　            try:
　　                if headers_sent:
　　                    # Re-raise original exception if headers sent
　　                    raise exc_info[0], exc_info[1], exc_info[2]
　　            finally:
　　                exc_info = None     # avoid dangling circular ref
　　        elif headers_set:
　　            raise AssertionError("Headers already set!")
　　
　　        headers_set[:] = [status,response_headers]
　　        return write
　　
　　    result = application(environ, start_response)
　　    try:
　　        for data in result:
　　            if data:    # body 出现以前不发送headers
　　                write(data)
　　        if not headers_sent:
　　            write(\'\')   # 如果这个时候body为空则发送header
　　    finally:
　　        if hasattr(result,\'close\'):
　　            result.close()
　　Django的服务器接口,django.core.servers.WSGIServer类.WSGIServer类继承于Python lib的HTTPServer类.
　　服务器启动开始与django.core.servers下的run()方法.它启动服务器接口,且传递一个应用程序接口WSGIHandler类的实例给服务器接口.
　　def run(addr, port, wsgi_handler, ipv6=False):
　　    server_address = (addr, port)
　　    httpd = WSGIServer(server_address, WSGIRequestHandler, ipv6=ipv6)
　　    httpd.set_app(wsgi_handler)
　　    httpd.serve_forever()
　　
　　class WSGIServer(HTTPServer):
　　    """BaseHTTPServer that implements the Python WSGI protocol"""
　　    application = None
　　
　　    def __init__(self, *args, **kwargs):
　　        if kwargs.pop(\'ipv6\', False):
　　            self.address_family = socket.AF_INET6
　　        HTTPServer.__init__(self, *args, **kwargs)
　　
　　    def server_bind(self):
　　        """Override server_bind to store the server name."""
　　        try:
　　            HTTPServer.server_bind(self)
　　        except Exception, e:
　　            raise WSGIServerException(e)
　　        self.setup_environ()
　　
　　    def setup_environ(self):
　　        # Set up base environment
　　        env = self.base_environ = {}
　　        env[\'SERVER_NAME\'] = self.server_name
　　        env[\'GATEWAY_INTERFACE\'] = \'CGI/1.1\'
　　        env[\'SERVER_PORT\'] = str(self.server_port)
　　        env[\'REMOTE_HOST\']=\'\'
　　        env[\'CONTENT_LENGTH\']=\'\'
　　        env[\'SCRIPT_NAME\'] = \'\'
　　
　　    def get_app(self):
　　        return self.application
　　
　　    def set_app(self,application):
　　        self.application = application
3.2.6 中间件:同时扮演两种角色的组件
　　注意到单个对象可以作为请求应用程序的服务器存在，也可以作为被服务器调用的应用程序存在。这样的中间件可以执行这样一些功能:
　　重写前面提到的 environ 之后，可以根据目标URL将请求传递到不同的应用程序对象
　　允许多个应用程序和框架在同一个进程中运行
　　通过在网络传递请求和响应，实现负载均衡和远程处理
　　对内容进行后加工，比如附加xsl样式表
　　中间件的存在对于服务器接口和应用接口来说都应该是透明的，并且不需要特别的支持。希望在应用程序中加入中间件的用户只需简单得把中间件当作应用提供给服务器，并配置中间件足见以服务器的身份来请求应用程序。
　　当然，中间件组件包裹的可能是包裹应用程序的另一个中间件组件，这样循环下去就构成了我们称为"中间件堆栈"的东西了。 for the most part,中间件要符合应用接口和服务器接口提出的一些限制和要求，有些时候这样的限制甚至比纯粹的服务器或应用程序还要严格，这些地方我们会特别指出。
　　这里有一个中间件组件的例子，他用Joe Strout的piglatin.py将text/plain的响应转换成pig latin（注意：真正的中间件应该使用更加安全的方式——应该检查内容的类型和内容的编码，同样这个简单的例子还忽略了一个单词might be split across a block boundary的可能性)。
　　from piglatin import piglatin
```
