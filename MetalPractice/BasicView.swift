//
//  BasicView.swift
//  MetalPractice
//

import MetalKit

class BasicView: MTKView {  //MTKViewを継承
    
    struct Vertex {
        var position: float3
        var color: float4
    }
    
    var commandQueue: MTLCommandQueue!  //コマンドキュー
    var renderPipelineState: MTLRenderPipelineState!
    
    var vertices: [Vertex]!
    
    var vertexBuffer: MTLBuffer!
    var fragmentBuffer: MTLBuffer!
    
    required init(coder: NSCoder) {  //初期化
        super.init(coder: coder)
        
        self.device = MTLCreateSystemDefaultDevice()
        
        self.clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0)
        
        self.colorPixelFormat = .bgra8Unorm
        
        self.commandQueue = device?.makeCommandQueue()
        
        createPipelineState()
        
        createVertices()
        
        createBuffer()
    }
    
    func createVertices(){
        vertices = [
            Vertex(position: float3( 0.0,  1.0, 0.0), color: float4(1.0, 0.0, 0.0, 1.0)),
            Vertex(position: float3(-1.0, -1.0, 0.0), color: float4(0.0, 1.0, 0.0, 1.0)),
            Vertex(position: float3( 1.0, -1.0, 0.0), color: float4(0.0, 0.0, 1.0, 1.0))
        ]
    }
    
    func createBuffer(){
        vertexBuffer = device?.makeBuffer(bytes: vertices, length: MemoryLayout<Vertex>.stride * vertices.count, options: [])
    }
    
    func createPipelineState(){
        let library = device?.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "basicVertexShader")
        let fragmentFunction = library?.makeFunction(name: "basicFragmentShader")
        
        var renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        
        do{
            renderPipelineState = try device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        }catch let error as NSError{
            print(error)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let drawable = self.currentDrawable, let renderPassDescriptor = self.currentRenderPassDescriptor else { return; }
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let renderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        
        renderCommandEncoder?.setRenderPipelineState(renderPipelineState)
        
        renderCommandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderCommandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        
        renderCommandEncoder?.setFragmentBuffer(fragmentBuffer, offset: 0, index: 0)
        
        renderCommandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
