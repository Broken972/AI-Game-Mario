from http.server import SimpleHTTPRequestHandler, HTTPServer
import os

class SimpleServerHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(b"Hello, this is a test response from your server!")

    def do_POST(self):
        # Lire la longueur des données
        content_length = int(self.headers['Content-Length'])
        # Lire les données envoyées
        post_data = self.rfile.read(content_length)

        # Enregistrer les données de la capture d'écran
        screenshot_path = "screenshot.png"
        with open(screenshot_path, "wb") as f:
            f.write(post_data)

        # Envoyer une réponse au client
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(b"Screenshot saved")

def run(server_class=HTTPServer, handler_class=SimpleServerHandler, port=8080):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f"Starting http server on port {port}")
    httpd.serve_forever()

if __name__ == "__main__":
    run()
