// M0 verifies the Deno Web APIs used by later Edge Functions; no provider call.
Deno.test("Edge runtime supports streaming UTF-8 responses", async () => {
  const text = "瞬间 · moment";
  const response = new Response(new ReadableStream({
    start(controller) {
      controller.enqueue(new TextEncoder().encode(text));
      controller.close();
    },
  }));
  if (await response.text() !== text) throw new Error("UTF-8 stream corrupted");
});
