from dotenv import load_dotenv
from livekit import agents
from livekit.agents import AgentSession, Agent, RoomInputOptions, ChatContext, ChatMessage
from livekit.plugins import google, noise_cancellation

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
    


if __name__ == "__main__":
    agents.cli.run_app(agents.WorkerOptions(entrypoint_fnc=entrypoint))

    