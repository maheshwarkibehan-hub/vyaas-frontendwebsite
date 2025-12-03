from dotenv import load_dotenv
from livekit import agents
from livekit.agents import AgentSession, Agent, RoomInputOptions, ChatContext, ChatMessage
from livekit.plugins import google, noise_cancellation
import asyncio
import os
from http.server import HTTPServer, BaseHTTPRequestHandler
from threading import Thread

# Import your custom modules
from vyaas_prompts import instructions_prompt, Reply_prompts
from vyaas_google_search import google_search, get_current_datetime
from vyaas_get_weather import get_weather

from memory_loop import MemoryExtractor


load_dotenv()


class Assistant(Agent):
    def __init__(self, chat_ctx) -> None:
        super().__init__(chat_ctx = chat_ctx,
                        instructions=instructions_prompt,
                        llm=google.beta.realtime.RealtimeModel(voice="Charon"),
                        tools=[
                                google_search,
                                get_current_datetime,
                                get_weather,
                        ]
                                )

async def entrypoint(ctx: agents.JobContext):
    session = AgentSession(
        preemptive_generation=False
    )
    
    #getting the current memory chat
    current_ctx = session.history.items
    

    await session.start(
        room=ctx.room,
        agent=Assistant(chat_ctx=current_ctx), #sending currenet chat to llm in realtime
        # room_input_options=RoomInputOptions(
        #     noise_cancellation=noise_cancellation.BVC()
        # ),
    )

    # Wait for 2 seconds to allow Android audio to initialize
    await asyncio.sleep(2)

    await session.generate_reply(
        instructions=Reply_prompts
    )
    conv_ctx = MemoryExtractor()
    await conv_ctx.run(current_ctx)
    

# Health Check Server for Render
class HealthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(b'{"status": "ok", "service": "VYAAS AI Agent"}')
    
    def log_message(self, format, *args):
        pass  # Suppress logs

def start_health_server():
    port = int(os.getenv('PORT', 10000))
    server = HTTPServer(('0.0.0.0', port), HealthHandler)
    print(f"Health server running on port {port}")
    server.serve_forever()

if __name__ == "__main__":
    # Start health check server in background thread
    health_thread = Thread(target=start_health_server, daemon=True)
    health_thread.start()
    
    # Start LiveKit agent
    agents.cli.run_app(agents.WorkerOptions(entrypoint_fnc=entrypoint))

    