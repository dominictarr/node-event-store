describe 'redis-stream storage', ->
    cli = null
    Redis = require 'redis-stream'
    es = require 'event-stream'
    redisStorage = require '../redis-stream-storage'
    beforeEach (done) ->
        cli = new Redis 6379, 'localhost', 11
        done()

    afterEach (done) ->
        flusher = cli.stream()
        flusher.on 'data', (reply) -> 
            flusher.end()
            done()
        flusher.write 'flushdb'



    describe '#read-stream', ->
        it 'should read all events', (done) ->
            sut = redisStorage
            commit1 =
                checkRevision: 0
                headers: []
                streamId: '123'
                streamRevision: 1
                payload: [
                    {a:1}
                    {b:2}
                    {c:3}
                ]
                timestamp: new Date(2012,9,1,12,0,0)
            seed = cli.stream('zadd', 'events:123', 1)
            seed.on 'end', ->
                sut.createStorage cli, (err, storage) ->
                    filter = 
                        streamId: '123'
                        minRevision: 0
                        maxRevision: Number.MAX_VALUE
                    storage.read filter, (err, result) ->
                        result.length.should.equal 3
                        done()
            seed.write JSON.stringify(commit1)
            seed.end()

    describe '#write-emit with old revision', ->
        it 'should return concurrency error', (done) ->
            sut = redisStorage
            commit1 =
                checkRevision: 0
                headers: []
                streamId: '123'
                streamRevision: 1
                payload: [
                    {a:1}
                ]
                timestamp: new Date(2012,9,1,12,0,0)
            commit =
                checkRevision: commit1.checkRevision
                headers: []
                streamId: '123'
                streamRevision: 4
                payload: [
                    {a:1}
                    {b:2}
                    {c:3}
                ]
                timestamp: new Date(2012,9,1,13,0,0)
            stream = cli.stream 'zadd', 'events:123', 1
            stream.on 'end', ->
                sut.createStorage cli, (err, storage) ->
                    emitter = storage.createCommitter()
                    emitter.on 'commit', (data) ->
                        done new Error('fail')
                    emitter.on 'error', (err) ->
                        err.should.exist
                        err.name.should.equal 'ConcurrencyError'
                        done()
                    emitter.write commit
            stream.write JSON.stringify(commit1)
            stream.end()
    describe '#write-emit', ->
        it 'should write commit ok', (done) ->
            sut = redisStorage
            commit =
                checkRevision: 0
                headers: []
                streamId: '123'
                streamRevision: 3
                payload: [
                    {a:1}
                    {b:2}
                    {c:3}
                ]
                timestamp: new Date(2012,9,1,13,0,0)

            sut.createStorage cli, (err, storage) ->
                emitter =  storage.createCommitter()
                emitter.on 'commit', (data)->
                    actual = cli.stream 'zrange', 'events:123', 0
                    actual.on 'data', (reply) ->
                        data = JSON.parse(reply)
                        data.should.exist
                        data.payload.should.eql commit.payload
                        done()
                    actual.write -1

                emitter.write commit
    describe '#write-emit again', ->
        it 'should write commit ok', (done) ->
            sut = redisStorage
            commit1 =
                checkRevision: 0
                headers: []
                streamId: '123'
                streamRevision: 1
                payload: [
                    {a:1}
                ]
                timestamp: new Date(2012,9,1,12,0,0)
            commit =
                checkRevision: 1
                headers: []
                streamId: '123'
                streamRevision: 4
                payload: [
                    {a:1}
                    {b:2}
                    {c:3}
                ]
                timestamp: new Date(2012,9,1,13,0,0)
            stream = cli.stream 'zadd', 'events:123', 1
            stream.on 'end', ->
                sut.createStorage cli, (err, storage) ->
                    emitter = storage.createCommitter()
                    emitter.on 'error', (err) ->
                        done new Error 'fail'
                    emitter.on 'commit', (data) ->
                        actual = cli.stream 'zrangebyscore', 'events:123', 0
                        replies = []
                        actual.on 'end', ->
                            replies.length.should.equal 2
                            replies[0].payload.should.eql commit1.payload
                            replies[1].payload.should.eql commit.payload
                            done()
                        actual.on 'data', (reply) ->
                            replies.push JSON.parse reply
                        actual.write 100
                        actual.end()
                    emitter.write commit
            stream.write JSON.stringify(commit1)
            stream.end()
    describe '#write-stream', ->
        it 'should write commit ok', (done) ->
            sut = redisStorage
            commit =
                checkRevision: 0
                headers: []
                streamId: '123'
                streamRevision: 3
                payload: [
                    {a:1}
                    {b:2}
                    {c:3}
                ]
                timestamp: new Date(2012,9,1,13,0,0)

            sut.createStorage cli, (err, storage) ->
                storage.write commit, (err, result) ->
                    args = ['events:123', 0, 4]
                    actual = cli.stream 'zrange', 'events:123', 0
                    data = null
                    actual.on 'error', (err) ->
                        console.log 'err', err
                        done(new Error 'fail')
                    actual.on 'end', ->
                        data.should.exist
                        done()
                    actual.on 'data', (reply) ->
                        data = reply
                    actual.write -1
                    actual.end()
    describe '#write-stream with old revision', ->
        it 'should return concurrency error', (done) ->
            sut = redisStorage
            commit1 =
                checkRevision: 0
                headers: []
                streamId: '123'
                streamRevision: 1
                payload: [
                    {a:1}
                ]
                timestamp: new Date(2012,9,1,12,0,0)
            commit =
                checkRevision: commit1.checkRevision
                headers: []
                streamId: '123'
                streamRevision: 4
                payload: [
                    {a:1}
                    {b:2}
                    {c:3}
                ]
                timestamp: new Date(2012,9,1,13,0,0)
            stream = cli.stream 'zadd', 'events:123', 1
            stream.on 'end', ->
                sut.createStorage cli, (err, storage) ->
                    storage.write commit, (err, result) ->
                        err.should.exist
                        err.name.should.equal 'ConcurrencyError'
                        done()
            stream.write JSON.stringify(commit1)
            stream.end()
    describe '#write-stream again', ->
        it 'should write commit ok', (done) ->
            sut = redisStorage
            commit1 =
                checkRevision: 0
                headers: []
                streamId: '123'
                streamRevision: 1
                payload: [
                    {a:1}
                ]
                timestamp: new Date(2012,9,1,12,0,0)
            commit =
                checkRevision: 1
                headers: []
                streamId: '123'
                streamRevision: 4
                payload: [
                    {a:1}
                    {b:2}
                    {c:3}
                ]
                timestamp: new Date(2012,9,1,13,0,0)
            stream = cli.stream 'zadd', 'events:123', 1
            stream.on 'end', ->
                sut.createStorage cli, (err, storage) ->
                    storage.write commit, (err, result) ->
                        actual = cli.stream 'zrangebyscore', 'events:123', 0
                        replies = []
                        actual.on 'end', ->
                            replies.length.should.equal 2
                            replies[0].payload.should.eql commit1.payload
                            replies[1].payload.should.eql commit.payload
                            done()
                        actual.on 'data', (reply) ->
                            replies.push JSON.parse reply
                        actual.write 100
                        actual.end()
            stream.write JSON.stringify(commit1)
            stream.end()

