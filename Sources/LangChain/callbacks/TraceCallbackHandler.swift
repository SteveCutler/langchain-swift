//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/9/11.
//

import Foundation

public class TraceCallbackHandler: BaseCallbackHandler {

    public override init() {
        super.init()
    }

    func truncate(_ text: String) -> String {
        String(text.prefix(50))
    }

    public override func on_llm_start(prompt: String, metadata: [String: String]) {
        print("🔍 [Trace] LLM Start: \(truncate(prompt))")
    }

    public override func on_llm_end(output: String, metadata: [String: String]) {
        print("🔍 [Trace] LLM End: \(truncate(output))")
    }

    public override func on_chain_error(error: Error, metadata: [String: String]) {
        print("🔍 [Trace] Chain Error: \(error.localizedDescription)")
    }

    public override func on_chain_end(output: String, metadata: [String: String]) {
        print("🔍 [Trace] Chain End: \(truncate(output))")
    }

    public override func on_chain_start(prompts: String, metadata: [String: String]) {
        print("🔍 [Trace] Chain Start: \(truncate(prompts))")
    }

    public override func on_tool_start(tool: BaseTool, input: String, metadata: [String: String]) {
        print("🔍 [Trace] Tool Start (\(tool.name())): \(truncate(input))")
    }

    public override func on_tool_end(tool: BaseTool, output: String, metadata: [String: String]) {
        print("🔍 [Trace] Tool End (\(tool.name())): \(truncate(output))")
    }

    public override func on_agent_start(prompt: String, metadata: [String : String]) {
        print("🔍 [Trace] Agent Start: \(truncate(prompt))")
    }

    public override func on_agent_action(action: AgentAction, metadata: [String: String]) {
        print("🔍 [Trace] Agent Action: \(action.action), Log: \(truncate(action.log))")
    }

    public override func on_agent_finish(action: AgentFinish, metadata: [String: String]) {
        print("🔍 [Trace] Agent Finish: \(truncate(action.final))")
    }

    public override func on_llm_error(error: Error, metadata: [String: String]) {
        print("🔍 [Trace] LLM Error: \(error.localizedDescription)")
    }
}

}
